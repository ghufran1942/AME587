function state = state(S,O)
    duration = fread(S,1,'float'); % Read 4 bytes (32 bits) from the Microcontroller
    fwrite(S,O,'uint8');
    state = duration * 0.0135 / 2; 
end
