function y = LognormalPdf(x, offset,mu,sigma)
% See lognormal parms in LognormalFit.m

    LognormalCheckParms(offset,mu,sigma);

    y = lognpdf(x-offset,mu,sigma);
    y(x <= offset) = 0;
    
end
