function NormCheckParms(mu,sigma)
% Produces an error if the parameters are invalid for a normal.

    if ~NormIsValid(mu,sigma)
        error('Invalid parameters for a normal (mu: %f, sigma: %f)',mu,sigma);
    end

end
