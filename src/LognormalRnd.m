function r = LognormalRnd(offs, mu, sigma, m, n)
% See lognormal parms in LognormalFit.m
%
% The resulting sample may have values equal to the offset (offs) due to a
% reason only (since the LN cannot generate naturally such cases): when 
% adding a large offset to a small value; this is due to numerical 
% imprecissions.
% This can happens also in a real scenario when we are measuring delays:
% some of them may come from a LN (continuous support, i.e., infinite
% precision) but become truncated in their precision.

global TOLROUNDTRIPS

    ConstantsInit();

    LognormalCheckParms(offs,mu,sigma);

    % logrnd() can produce datum too close to 0 that, if added to a large
    % offset, produce data equal to the offset.
    r = lognrnd(mu,sigma,m,n);
    
    r = r + offs;

end
