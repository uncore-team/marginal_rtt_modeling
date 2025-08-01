function [ok,a,b] = UnifFit(ds)
% Fit a uniform to the given data through MLE.
%
% It always return 1 in OK except if too few data (in that case, return NaN
% in a and b).
global TOLROUNDTRIPS

    ConstantsInit();

    ok = 0;
    a = NaN;
    b = NaN;

    if ~SampleIsValid(ds)
        return; 
    end

    n = length(ds);

    % This comes from https://real-statistics.com/distribution-fitting/distribution-fitting-via-maximum-likelihood/fitting-uniform-parameters-via-mle/
    % that is copied in docs/roundtrips/Fitting Uniform Parameters MLE _ Real Statistics Using Excel.pdf
    % (using a = min(ds) and b = max(ds) is biased; the following tries to
    % find unbiased fit)
    x1 = min(ds);
    xn = max(ds);
    a = x1;
    b = xn;
    tol = 1e-10;
    np1dn = (n + 1)/n;
    nitsmax = 1000;
    nits = 0;
    finish = 0;
    while ~finish
        na = b + np1dn * (x1 - b); % the new A uses the old B
        nb = a + np1dn * (xn - a); % the new B uses the old A
        da = abs(a-na);
        db = abs(b-nb);
        if (da < tol) && (db < tol)
            finish = 1;
        end
        a = na;
        b = nb;
        nits = nits + 1;
        if nits > nitsmax % usually converges in few iterations
            finish = 1; % note: just one iteration will provide some close to unbiased values
        end
    end

    % assure the fit is valid (see UnifIsValid()
    if (b <= a) || (b <= 0)
        a = NaN;
        b = NaN;
        return; % no fit
    end
    if (a <= 0)
        a = TOLROUNDTRIPS; 
        if b <= a
            b = b + TOLROUNDTRIPS;
            if b <= a % should not happen
                a = NaN;
                b = NaN;
                return; % no fit
            end
        end
    end

    ok = 1;

end