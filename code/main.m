%AME 587 Project

clc; clear; close all 
delete(instrfind()); % Clear serial port
S = serial('COM4'); % Serial port configuration
set(S,'BaudRate',19200,'InputBufferSize',4); % Set Baud Rate = 19200 and Number of Bytes = 2, same as Microcontroller
fopen(S); % Open serial port
figure('units','normalized','outerposition',[0.2 0.2 0.5 0.7]); set(gcf,'color','w'); 
Plot = animatedline('LineWidth',1,'Color','b'); grid on; box on; 
Plot2 = animatedline('LineWidth',1,'Color','g'); grid on; box on; 
Plot3 = animatedline('LineWidth',1,'Color','r'); grid on; box on; 
title('Serial Data','FontSize',12); xlabel('Elapsed Time (s)','FontSize',9); ylabel('Amplitude (units)','FontSize',9)
Time = zeros(1,10000); Filtered  = zeros(size(Time)); Controlled = zeros(size(Time)); 
fwrite(S,0,'async'); tic % Start the communication and the stopwatch timer

Q=rand(20,3);
xold = [];
% range = 1/0.0135 %range around the target; set for 1 inch total
% Training Code


for i = 1:10000
   Error(i) = fread(S,1,'float');
   Filtered(i) = Error(i); % Filter
   Controlled(i) = Filtered(i); % Controller
   fwrite(S,128,'uint8'); % Send 1 byte back to the Microcontroller
   Time(i) = toc;
   addpoints(Plot,Time(i),Error(i)); 
   axis([toc-10 toc+1 -10 10000]); % Axis based on elapsed time
   pause(0.01);
end
% 
% for k=1:20 % Number of Episodes
% 
%     xT=10; %Specific target location in inches
% 
%     pfwd=0.7;
% 
%     alp=0.31;
% 
%     gam=0.1;
% 
%     N=540;
%     
%     % Set the initial state
% %     x(1) = state(S,1);
% 
%     duration = fread(S,1,'float'); % Read 4 bytes (32 bits) from the Microcontroller
%     fwrite(S,1,'uint8');
%     x(1) = duration * 0.0135 / 2; 
% 
%     count = 0;
%     for i = 1:N
%         % Choose an action based on the learned Q-table
%         [~, a] = max(Q(round(x(i)), :));
% 
% %         movement(a);
%         
%         pause(0.1); %Allows some time for movement before checking the sensor
% 
%         % Read the updated state from the sensor
%         duration = fread(S,1,'float'); % Read 4 bytes (32 bits) from the Microcontroller
%         fwrite(S,0,'uint8');
%         x(i+1) = duration * 0.0135 / 2; 
% 
% %         x(i+1) = state(S,0);
% 
%         % Update the Q-table using the Q-learning update rule
%         [~, a_next] = max(Q(round(x(i+1)), :));
%         
%         % Calculate the reward
%         if abs(x(i+1)-xT)< abs(x(i)-xT)
%             r(i) = 0;
%         else
%             r(i) = -1;
%         end
% 
%         Q(round(x(i)),a)=Q(round(x(i)),a)+alp*(r(i)-gam*Q(round(x(i+1)),a_next)-Q(round(x(i)),a));
% 
%         xold(k, i) = x(i);
% 
%         at_target = round(x(i+1)) == xT; %Determines if the current position is close enough to the target
%         
%         % Check to see if we are outside the range or not
%         if at_target
%             count = count + 1;
%         else
%             count = 0;
%         end
%         if count >= 2 %Exits the loop early if the user stays within the bounds for ~2 seconds
%             break;
%         end
% 
%     end
%     pause(.5);
% 
% end
% 
% % Testing Code
% 
% for i= 1:N
%     [~,a] = max(Q(round(x(i)),:));
% 
% %     movement(a)
% 
%     duration = fread(S,1,'float'); % Read 4 bytes (32 bits) from the Microcontroller
%     fwrite(S,0,'uint8');
%     x(i+1) = duration * 0.0135 / 2; 
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