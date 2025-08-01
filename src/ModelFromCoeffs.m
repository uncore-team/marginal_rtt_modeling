function m = ModelFromCoeffs(v)
% Given a row vector V created with ModelToCoeffs, recover the model. It
% also checks if the model is valid; get an undefined model if invalid or
% if the parameters were not recovered well.
%
% V -> row vector with coeffs (see ModelToCoeffs).
% 
% M <- model (see ModelCreate).

    switch v(1)
        case 0 % LL3

            m = ModelCreate('LL3');
            m.coeffs.a = v(2);
            m.coeffs.b = v(3);
            m.coeffs.c = v(4);

        case 1 % EXP2

            m = ModelCreate('EXP2');
            m.coeffs.alpha = v(2);
            m.coeffs.beta = v(3);

        case 2 % LN3

            m = ModelCreate('LN3');
            m.coeffs.gamma = v(2);
            m.coeffs.mu = v(3);
            m.coeffs.sigma = v(4);

        case 3 % BERN

            m = ModelCreate('BERN');
            m.coeffs.ind0 = v(2);
            m.coeffs.ind1 = v(3);

        case 4 % NORM

            m = ModelCreate('NORM');
            m.coeffs.mu = v(2);
            m.coeffs.sigma = v(3);

        case 5 % UNIF

            m = ModelCreate('UNIF');
            m.coeffs.a = v(2);
            m.coeffs.b = v(3);
            
        otherwise
            error('Invalid model type');
    end

    if ModelIsValid(m,1)
        m.defined = 1;
    end    

end