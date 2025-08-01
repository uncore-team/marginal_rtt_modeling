function va = NormIsValid(mu,sigma)
% Return 0 if the parameters are invalid for a normal.

    if isnan(mu) || isnan(sigma) || isinf(mu) || isinf(sigma) || ...
       (mu <= 0) || (sigma <= 0)
        va = 0;
    else 
        va = 1;
    end

end