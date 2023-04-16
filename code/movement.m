function movement(a)
    switch a
        case 1
            move_sensor_left();
        case 2
            stay();
        case 3
            move_sensor_right();
        otherwise 
            disp('Unknown Command');
    end
end

function move_sensor_left()
    fread(Serial,1,'float');
    fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.1);
    fread(Serial,1,'float');
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
end

function move_sensor_right()
    fread(Serial,1,'float');
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.45);
    fread(Serial,1,'float');
    fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
end

function stay()
    fread(Serial,1,'float');
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.65);
    fread(Serial,1,'float');
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
end