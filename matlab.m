clc; clear; close all 
delete(instrfind()); % Clear serial port
S = serial('COM4'); % Serial port configuration
set(S,'BaudRate',19200,'InputBufferSize',4); % Set Baud Rate = 19200 and Number of Bytes = 2, same as Microcontroller
fopen(S); % Open serial port
figure('units','normalized','outerposition',[0.2 0.2 0.5 0.7]); set(gcf,'color','w'); 
Plot = animatedline('LineWidth',1,'Color','b'); grid on; box on;
title('Serial Data','FontSize',12); xlabel('Elapsed Time (s)','FontSize',9); ylabel('Amplitude (units)','FontSize',9)
Time = zeros(1,1000); Error = zeros(size(Time)); Filtered  = zeros(size(Time)); Controlled = zeros(size(Time)); 
fwrite(S,0,'async'); tic % Start the communication and the stopwatch timer
for i = 1:length(Time)
   Error(i) = fread(S,1,'float32');
   Filtered(i) = Error(i); % Filter
   Controlled(i) = Filtered(i); % Controller
   fwrite(S,Controlled(i),'uint8'); % Send 1 byte back to the Microcontroller
   Time(i) = toc;
   addpoints(Plot,Time(i),Error(i)); 
   axis([toc-10 toc+1 -10 30]); % Axis based on elapsed time
   pause(0.01);
end
fclose(S);
delete(S);
clear S; % Close and clear serial port