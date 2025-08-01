function va = LoglogisticIsValid(a,b,c)
% Return 0 if the parms are invalid.

    if isnan(a) || isnan(b) || isnan(c) || isinf(a) || isinf(b) || isinf(c) || ...
       (a <= 0) || (c <= 0) || (c > 0.5) || (b <= 0)
        va = 0;
    else
        va = 1;
    end

end