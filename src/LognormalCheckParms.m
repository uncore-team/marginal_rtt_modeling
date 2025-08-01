function LognormalCheckParms(offs,mu,sigma)
% Produce an error if the parms are invalid.

    if ~LognormalIsValid(offs,mu,sigma)
        error('Invalid parameters for a lognormal');
    end

end