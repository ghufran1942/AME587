%{
Determines the motion of 
%}
function decideMotion(xQ,xUltra,S)
    if xQ < xUltra - 0.5 % Buzzes left if target is left of current position
        movement(1,S);
    elseif xQ > xUltra + 0.5 % Buzzes right if target is right of current position
        movement(3,S);
    else % Does not buzz if at the target
        movement(2,S);
    end
end

