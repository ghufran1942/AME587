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

Q=rand(20,3); xold=[];

for k=1:10 %Number of training targets for the Q-table

    x_ini=randi(20)

    xT=10;

    pfwd=0.7;

    alp=0.31;

    gam=0.1

    eps0=1;eps=eps0;

    N=540;

    x(1)=x_ini;
    
    for i=1:N %while true %loop will not break until target is reached
        % chose an action from state x(i)

        [~,a] =  max(Q(x(i),:));

        c=rand;if c<eps, a=a; else a=randi(3);end

        eps=eps+(1-eps0)/N;

        x(i+1)=x(i)+(a-2)*randsrc(1,1,[1 -1;pfwd  1-pfwd]) ; % motion of human based on action

            if x(i+1)>=20, x(i+1)=20;end

        if x(i+1)<=1, x(i+1)=1;end

    

        [~,a_next] = max(Q(x(i+1),:));  % get future action

        if abs(x(i+1)-xT)< abs(x(i)-xT), r(i)=0;

        else r(i)=-1; end

        Q(x(i),a)=Q(x(i),a)+alp*(r(i)-gam*Q(x(i+1),a_next)-Q(x(i),a));

        xold(k,i)=x(i);
        for j = 1:length(Time)
           cur_dur = fread(S,1,'uint16'); % Read 2 bytes (16 bits) from the Microcontroller
           range = 37.5; %1 inch ~ 150 us
           LB = prev_dur - range;
           UB = prev_dur + range;
           dist = prev_dur * 0.0135 / 2;
           if (cur_dur >= UB) || (cur_dur <= LB)
               prev_dur = cur_dur;
               % PWM for motor 1/driver outputs 1&2
               % PWM comes from q-table
               % [_,PWM1] = max(Q(x(i),:));
               % PWM2 = 255 - PWM1;
               fwrite(S,1,'uint8'); % Send 1 byte back to the Microcontroller
               fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
               pause(2);
               fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
           else
               fwrite(S,0,'uint8'); % Send 1 byte back to the Microcontroller
               fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
               fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
               continue;
           end
           
           Time(j) = toc;
           addpoints(Plot,Time(j),dist);
           axis([toc-10 toc+1 -10 300]); % Axis based on elapsed time
           legend('Analog input')
        
           %Q-update
           Q(x(j),a)=Q(x(j),a)+alp*(r(j)-gam*Q(x(j+1),a_next)-Q(x(j),a));
           pause(0.01);
        end
    end

    

end

% x(1)=randi(20); %randi([min(xold) max(xold)]);

 

% for i=1:N,
% 
%     % chose an action from state x(i)
% 
%     [~,a] = max(Q(x(i),:));
%     %Write to pic ==> wait for response as x(i+1)
%     fwrite(S,4,'uint8');
%     pause(0.01);
%     x(i+1) = fread(S,1,'uint8'); %New position
% 
%     if x(i+1)>=20, x(i+1)=20;end
% 
%     if x(i+1)<=1, x(i+1)=1;end
% 
%     [~,a_next] = max(Q(x(i+1),:));  % get future action
% 
%     if abs(x(i+1)-xT)< abs(x(i)-xT), r(i)=0;
% 
%     else r(i)=-1; end
% 
% end


%%Plotting/Communication section
fclose(S);
delete(S);
clear S; % Close and clear serial port
% figure
% 
% hold
% 
% for k=1:10,plot(xold(k,:));end
% 
% plot(x,'r')
% xlim([0 21])
% 
% legend({'Training data','Training data','Training data','Training data','Training data','Training data','Training data','Training data','Training data','Training data', 'Trained'})
% 
% xlabel('Time, t');ylabel('State,s(t)')
% 
% shg
% 
% figure
% 
% bar3(Q+1);shg