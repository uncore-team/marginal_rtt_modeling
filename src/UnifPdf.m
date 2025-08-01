function ys = UnifPdf(xs,a,b)
% Return the pdf of that uniform at the given XS.

    ys = ones(1,length(xs));
    ys((xs < a) | (xs > b)) = 0;
    ys = ys / (b - a);

end