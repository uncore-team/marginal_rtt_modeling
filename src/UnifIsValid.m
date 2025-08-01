function va = UnifIsValid(a,b)
% Return 0 if the parameters are invalid for an uniform.

    if isnan(a) || isnan(b) || isinf(a) || isinf(b) || ...
       (a <= 0) || (a >= b)
        va = 0;
    else
        va = 1;
    end

end