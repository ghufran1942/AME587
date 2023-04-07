function state = state(S)
    duration = fread(S,1,'uint16'); % Read 2 bytes (16 bits) from the Microcontroller
    state = duration * 0.0135 / 2;
end
