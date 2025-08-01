function ExponentialCheckParms(alpha,beta)
% Gives an error if ALPHA,BETA are not valid.
% See the distrib. parameters in ExponentialFit.

	if ~ExponentialIsValid(alpha,beta)
        error('Invalid parameters for exponential distr.');
    end

end
