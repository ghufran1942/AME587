function movement(a,S)
    switch a
        case 1
            move_sensor_left(S);
        case 2
            stay(S);
        case 3
            move_sensor_right(S);
        otherwise 
            disp('Unknown Command');
    end
    pause(0.5);
end

function move_sensor_left(S)
    fread(S,1,'float');
    fwrite(S,45,'uint8'); % Send 1 byte back to the Microcontroller
end

function move_sensor_right(S)
    fread(S,1,'float');
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
end

function stay(S)
    fread(S,1,'float');
    fwrite(S,0,'uint8'); % Send 1 byte back to the Microcontroller  
end