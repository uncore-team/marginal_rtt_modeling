function v = ModelToCoeffs(m)
% Return a row vector with the parameters of the model
%
% M -> model (see ModelCreate).
%
% V <- row vector with the parameters plus additional NaN elements to
%      always occupy the same size unregarding the model type. The first
%      element is always a numerical code for the type of the model, and
%      the second and others are the parameters, being always the second
%      one the offset if the model has that.

    if ~m.defined
        error('Undefined model cannot be converted to vector');
    end

    if strcmp(m.type,'LL3')

        v = [0,m.coeffs.a,m.coeffs.b,m.coeffs.c];

    elseif strcmp(m.type,'EXP2')

        v = [1,m.coeffs.alpha,m.coeffs.beta,NaN];

    elseif strcmp(m.type,'LN3')

        v = [2,m.coeffs.gamma,m.coeffs.mu,m.coeffs.sigma];

    elseif strcmp(m.type,'BERN')

        v = [3,m.coeffs.ind0,m.coeffs.ind1,NaN];

    elseif strcmp(m.type,'NORM')

        v = [4,m.coeffs.mu,m.coeffs.sigma,NaN];

    elseif strcmp(m.type,'UNIF')

        v = [5,m.coeffs.a,m.coeffs.b,NaN];
        
    else
        error('Invalid model type');
    end    

end