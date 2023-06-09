% AME 587 Project

% Running Matlab using commanda line:
% ON Windows matlab can be run from cmd using the following command: matlab -nodisplay -nosplash -nodesktop -r "run('[filename]');"
% The same command can be used to run in linux system too. To display the command window output remove the -nodisplay argument.

clc; clear; close all 
delete(instrfind()); % Clear serial port
S = serial('COM4'); % Serial port configuration
set(S,'BaudRate',19200,'InputBufferSize',4); % Set Baud Rate = 19200 and Number of Bytes = 2, same as Microcontroller
fopen(S); % Open serial port
figure('units','normalized','outerposition',[0.2 0.2 0.5 0.7]); set(gcf,'color','w'); 
title('Serial Data','FontSize',12); xlabel('Elapsed Time (s)','FontSize',9); ylabel('Amplitude (units)','FontSize',9)
Time = zeros(1,10000); Filtered  = zeros(size(Time)); Controlled = zeros(size(Time)); 
fwrite(S,0,'async'); 

% % Generate Random Q Table
% Q=rand(30,3);
% save("Q_Random.mat","Q")

% % Import Q Table
Q = importdata("Q_Random.mat");
% Q = zeros(30,3);
FOLDER = '6_data';
% episode = 10;
% location = sprintf('%s/Q_table_with_eps_rate_exp(-k100)_%d.mat',FOLDER,episode);
% Q = importdata(location);

% file_location = sprintf('%s/Trajectory_eps_%d.mat',FOLDER,episode);
% xold = importdata(location);
%xT= round(23*rand(20,1)+4); %Specific target location in inches
xT = 15; % Target
%xT = 10*ones(20,1);

eps=1;
for k=1:40 % Number of Episodes
    disp('Starting Next Round')
    pause(2);
    Plot = animatedline('LineWidth',1,'Color','b'); grid on; box on; 
    Plot2 = animatedline('LineWidth',1,'Color','g'); grid on; box on; 
    pfwd=0.7;
    
    % Fixed Alpha
    alp = 0.31
    
    % Low Alpha
%     alp = 0.1

    % Medium Alpha
%     alp = 0.5

    % High Alpha
%     alp = 0.9

    % Epsilon is Decreasing Exponential
    eps = exp(-k/100)

    gam=0.1;

    N=60;
    
    % Set the initial state
    x(1) = state(S,0);

%     duration = fread(S,1,'float'); % Read 4 bytes (32 bits) from the Microcontroller

%     fwrite(S,1,'uint8');
    
    decideMotion(xT,x(1),S); % Determines which buzzer to use
    exitRun = 0; % Counter for exiting loop if user stays at target for some time
    tic % Start the stopwatch timer
    for i = 1:N
        % Choose an action based on the learned Q-table
        [~, a] = max(Q(round(x(i)), :));
        
        c=rand;
        if c>eps
            % Exploration
            a=a;
            disp("Q Table Action")
        else 
            % Exploitation
            a=randi(3);
            disp("Random Action")
        end

        movement(a,S);

        % Read the updated state from the sensor
        x(i+1) = state(S,0);

        % Update the Q-table using the Q-learning update rule   
        [~, a_next] = max(Q(round(x(i+1)), :));
        
        % eps=eps+(1-eps0)/N;

        % Holds current action until user holds in place for some time
        last_state = -1;
        count = 0;
        while true
            current = state(S,a);
            if abs(current - last_state) < 1
                count = count + 1;
                if count > 10
                    break;
                end
            end
            last_state = current;
        end

        at_target = abs(x(i+1) - xT) < 1; %Determines if the current position is close enough to the target
        % Calculate the reward
        if at_target
            r(i) = 10;
            a = 2;
        elseif abs(x(i+1)-xT) < abs(x(i)-xT)
            r(i) = 1;
        elseif abs(x(i+1)-xT) >= abs(x(i)-xT)
            r(i) = -1;
        else
            r(i) = 0;
        end

        Q(round(x(i)),a)=Q(round(x(i)),a) + alp*(r(i)+gam*Q(round(x(i+1)),a_next) - Q(round(x(i)),a));

        xold(k, i) = x(i);
        
        % Check to see if we are outside the range or not
        if at_target
            exitRun = exitRun + 1;
        else
            exitRun = 0;
        end
        if exitRun >= 2 %Exits the loop early if the user stays within the bounds for ~2 seconds
            disp("Reached Target")
            break;
        end

        Time(i) = toc;
        addpoints(Plot,Time(i),x(i)); 
        addpoints(Plot2,Time(i),xT);
        axis([toc-10 toc+1 0 30]); % Axis based on elapsed time
        pause(0.01);
    end
    save(sprintf('%s/Trajectory_eps_%d',FOLDER,k),'xold');
    save(sprintf('%s/Q_table_with_eps_rate_exp(-k100)_%d',FOLDER,k),'Q');
    delete(Plot);
    delete(Plot2);
    movement(2,S);
    disp('=============================================================')
    disp('Next Round')
    beep on
    pause(1);
    beep off
end
figure(2);
bar3(Q);
title(sprintf('Updated Q-table: After %d rounds',k));
figure(3);
% bar3(Q_old);
bar3(importdata("Q_Random.mat"))
title('Initial Q-table');

% % Trajectories Plot
figure(4);
file_path = sprintf('%s/trajectory_eps_%d.mat',FOLDER,k);
trajectories = importdata(file_path);
hold on;
for i=1:10
    plot(trajectories(i,:))
end
hold off
% plot(x,'r')
xlabel('Time, t');ylabel('State,s(t)')

for i=1:10
    plot(trajectories(k,:))
end
hold off

w = waitforbuttonpress;

movement(2,S)
pause(2)

% Testing Code

% for i= 1:N
%     [~,a] = max(Q(round(x(i)),:));
% 
%     movement(a,S)
% 
%     % duration = fread(S,1,'float'); % Read 4 bytes (32 bits) from the Microcontroller
%     % fwrite(S,0,'uint8');
%     % x(i+1) = duration * 0.0135 / 2; 
% 
%     x(i+1) = state(S,0);
% 
%     at_target = round(x(i+1)) == xT;
% 
%     % Calculate the reward
%     if abs(x(i+1)-xT)< abs(x(i)-xT)
%         r(i) = 0;
%     else
%         r(i) = -1;
%     end
% 
%     [~, a_next] = max(Q(round(x(i+1)), :));
%     Q(round(x(i)),a)=Q(round(x(i)),a)+alp*(r(i)-gam*Q(round(x(i+1)),a_next)-Q(round(x(i)),a));
% 
%     if at_target
%         break;
%     end
% 
% 
% end

%%Plotting/Communication section
fclose(S);
delete(S);
clear S; % Close and clear serial port