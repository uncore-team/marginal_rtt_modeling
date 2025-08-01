function [ok,mu,sigma] = NormFit(ds)
% Fit a normal to the given data through MLE.
%
% It always return 1 in OK except if too few data (in that case, return NaN
% in mu and sigma).

    ok = 0;
    mu = NaN;
    sigma = NaN;

    if ~SampleIsValid(ds)
        return; 
    end
    
    mu = mean(ds); % estimate mu and sigma as the ones of that normal (MLE)
    sigma = std(ds);

    % assure it is valid (see NormIsValid())
    if (sigma <= 0) || (mu <= 0) % cannot recover from that
        mu = NaN;
        sigma = NaN;
        return;
    end

    ok = 1;

end