function va = LognormalIsValid(offs,mu,sigma)
% Return 0 if the parms are invalid.

    if isnan(offs) || isnan(mu) || isnan(sigma) || isinf(offs) || isinf(mu) || isinf(sigma) || ...
       (offs < 0) || (sigma <= 0)
        va = 0;
    else
        va = 1;
    end

end