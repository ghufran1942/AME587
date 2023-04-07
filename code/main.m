%AME 587 Project

clc; clear; close all 
delete(instrfind()); % Clear serial port
S = serial('COM9'); % Serial port configuration
set(S,'BaudRate',19200,'InputBufferSize',2); % Set Baud Rate = 19200 and Number of Bytes = 2, same as Microcontroller
fopen(S); % Open serial port
figure('units','normalized','outerposition',[0.2 0.2 0.5 0.7]); set(gcf,'color','w'); 
Plot = animatedline('LineWidth',1,'Color','b'); grid on; box on; 
Plot2 = animatedline('LineWidth',1,'Color','g'); grid on; box on; 
Plot3 = animatedline('LineWidth',1,'Color','r'); grid on; box on; 
title('Serial Data','FontSize',12); xlabel('Elapsed Time (s)','FontSize',9); ylabel('Amplitude (units)','FontSize',9)
Time = zeros(1,5000); Filtered  = zeros(size(Time)); Controlled = zeros(size(Time)); 
fwrite(S,0,'async'); tic % Start the communication and the stopwatch timer

Q=rand(20,3);
xold = [];

% Training Code

for k=1:100 % Number of Episodes

    xT=10;

    pfwd=0.7;

    alp=0.31;

    gam=0.1;

    eps0 = 1;
    eps = eps0;

    N=540;
    
    % Set the initial state
    x(1) = state();

    for i = 1:N
        % Choose an action based on the learned Q-table
        [~, a] = max(Q(x(i), :));

        movement(a);
        
        % Read the updated state from the sensor
        x(i+1) = state();

        % Check to see if we are outside the range or not (Code Not Added)
        
        eps = eps + (1 - eps0) / N;

        % Update the Q-table using the Q-learning update rule
        [~, a_next] = max(Q(x(i+1), :));

        % Calculate the reward
        if abs(x(i+1)-xT)< abs(x(i)-xT)
            r(i) = 0;
        else
            r(i) = -1;
        end

        Q(x(i),a)=Q(x(i),a)+alp*(r(i)-gam*Q(x(i+1),a_next)-Q(x(i),a));

        xold(k, i) = x(i);

    end
    pause(5);

end

% Testing Code

for i= 1:N
    [~,a] = max(Q(x(i),:));

    movement(a)

    x(i+1) = state();

    at_target = (abs(x(i+1) - xT) < threshold);

    % Calculate the reward
    if abs(x(i+1)-xT)< abs(x(i)-xT)
        r(i) = 0;
    else
        r(i) = -1;
    end

    [~, a_next] = max(Q(x(i+1), :));
    Q(x(i),a)=Q(x(i),a)+alp*(r(i)-gam*Q(x(i+1),a_next)-Q(x(i),a));

    if at_target
        break;
    end


end

%%Plotting/Communication section
fclose(S);
delete(S);
clear S; % Close and clear serial port