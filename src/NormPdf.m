function ys = NormPdf(xs,mu,sigma)
% Return the PDF for the given XS of that normal

    NormCheckParms(mu,sigma);

    ys = normpdf(xs,mu,sigma);

end