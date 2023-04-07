function movement(a)
    % Control the ultrasonic sensor's movement based on the chosen action

    if a == 1
        move_sensor_left();
    elseif a == 2
        stay();
    elseif a == 3
        move_sensor_right();
    end
end

function move_sensor_left()
    fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
    pause(2);
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
end

function move_sensor_right()
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
    pause(2);
    fwrite(S,100,'uint8'); % Send 1 byte back to the Microcontroller
end

function stay()
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
    pause(2);
    fwrite(S,200,'uint8'); % Send 1 byte back to the Microcontroller
end