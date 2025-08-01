function [alpha,beta] = ExponentialOffset(x)
% Estimate the parameters of the Exponential through MLE as much as
% possible. It is separated from ExponentialFit in order to be reused by
% other distributions.

    n = length(x);
    minx = min(x);
    mu = mean(x);
    beta = (mu - minx) * n / (n - 1); % estimate of the (non-shifted) mean
    alpha = minx - beta / n; % estimate of the offset
    if alpha < 0 % in that case we revert to the MLE, biased estimators
        beta = mu - minx;
        alpha = minx; % offset
    end

end
