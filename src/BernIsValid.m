function va = BernIsValid(ind0,ind1)
% Return 0 if the parms are invalid.

    if isnan(ind0) || isnan(ind1) || isinf(ind0) || isinf(ind1) || ...
       (fix(ind0) ~= ind0) || (fix(ind1) ~= ind1) || ...
       (ind0 <= 0) || (ind1 < ind0)
        va = 0;
    else
        va = 1;
    end

end