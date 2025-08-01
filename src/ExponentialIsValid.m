function va = ExponentialIsValid(alpha,beta)
% Return 0 if ALPHA,BETA are not valid.
% See the distrib. parameters in ExponentialFit.

	if isnan(alpha) || isnan(beta) || isinf(alpha) || isinf(beta) || ...
       (alpha < 0) || (beta <= 0)
        va = 0;
    else
        va = 1;
    end

end
