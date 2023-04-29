function state = state(Serial,Output)
    duration = fread(Serial,1,'float'); % Read 4 bytes (32 bits) from the Microcontroller
    fwrite(Serial,Output,'uint8');
    state = duration * 0.0135 / 2; % Distance in inches
    if state > 30
        state = 30;
    elseif state < 1
        state = 1;
    end
end
