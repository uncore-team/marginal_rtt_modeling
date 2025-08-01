function va = ModelIsValid(mo,checkundef)
% Given a model in MO, return 1 if the model is valid.
%
% MO -> model (see ModelCreate).
% CHECKUNDEF -> 0 to not check the model if it is undefined; 1 to check it
%               even being undefined.

    va = 0;
    if (~checkundef) && (~mo.defined)
        return;
    end

    if strcmp(mo.type,'EXP2')
    
        va = ExponentialIsValid(mo.coeffs.alpha,mo.coeffs.beta);

    elseif strcmp(mo.type,'LN3')

        va = LognormalIsValid(mo.coeffs.gamma,mo.coeffs.mu,mo.coeffs.sigma);

    elseif strcmp(mo.type,'LL3')

        va = LoglogisticIsValid(mo.coeffs.a,mo.coeffs.b,mo.coeffs.c);

    elseif strcmp(mo.type,'BERN')

        va = BernIsValid(mo.coeffs.ind0,mo.coeffs.ind1);

    elseif strcmp(mo.type,'NORM')

        va = NormIsValid(mo.coeffs.mu,mo.coeffs.sigma);

    elseif strcmp(mo.type,'UNIF')

        va = UnifIsValid(mo.coeffs.a,mo.coeffs.b);
        
    else
        error('Unknown kind of model');
    end

end