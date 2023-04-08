function movement(a)
    switch a
        case 1
            move_sensor_left();
        case 2
            stay();
        case 3
            move_sensor_right();
        otherwise 
            disp('zilch');
    end
end

function move_sensor_left()
    fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.5);
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
end

function move_sensor_right()
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.5);
    fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
end

function stay()
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
    pause(0.5);
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
end