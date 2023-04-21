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
end

function move_sensor_left(S)
    fread(S,1,'float');
    fwrite(S,25,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.5);
end

function move_sensor_right(S)
    fread(S,1,'float');
    fwrite(S,220,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.5);
end

function stay(S)
    fread(S,1,'float');
    fwrite(S,127,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.5);
    
end