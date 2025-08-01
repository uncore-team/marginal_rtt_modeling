function [alpha,beta,ok] = ExponentialFit(x)
% Estimates a shifted exponential that fits X in the MLE sense.
% This uses the shifted exponential defined in D'Agostino p. 133, from
% where we have: pdf(x;alpha,beta) = 1/beta * exp(-(x-alpha)/beta).
% expectation == beta + alpha; median == ln2 * beta + alpha; variance == beta^2
%
% Such an exponential distribution may generate samples with values equal
% to the offset. The offset estimation in this function may produce such
% case.
%
% Wikipedia: pdf(x;alpha,lambda) = lambda * exp(-lambda*(x-alpha)); expectation == 1/lambda + alpha; median == ln2/lambda + alpha == ln2 * (expectation - alpha) + alpha
% Matlab: it has only the non-shifted distrib. where pdf(x,mu) = 1/mu * exp(-x/mu)
%
% From Wikipedia to Here: beta = 1/lambda
% From Here to Wikipedia: lambda = 1/beta
% From Here to Matlab: mu = beta
% From Matlab to Here: beta = mu (alpha = 0)
%
% X -> (possibly unordered) sample.
%
% ALPHA <- offset (location); it will be >= 0.
% BETA <- the non-shifted mean (shape); it will be > 0.
% OK <- 1 if there are enough values in the sample to do the fitting.

global TOLROUNDTRIPS

    ConstantsInit();

    ok = 0;
    alpha = NaN;
    beta = NaN;

    if ~SampleIsValid(x)
        return; 
    end
   
    % --- unbiased MLE estimation:
    [alpha,beta] = ExponentialOffset(x);

    % assure it is valid (see ExponentialIsValid())
    if beta <= 0 % cannot recover from that
        alpha = NaN;
        beta = NaN;
        return;
    end
    % alpha > 0 here

    ok = 1;

end