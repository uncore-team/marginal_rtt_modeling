function sqd = sqdist_distrib(theopdffunx,data)
% Calculate the sum of squared distances between the sample DATA and the
% theoretical pdf calculated by the function THEOPDFFUNX.
%
% THEOPDFFUNX -> function that admits a vector of x values and return the
%                corresponding pdf evaluated at them.
% DATA -> experimental sample.
%
% SQD <- sum of squared distances of both.

    [yshist,ehist] = histcounts(data,'Normalization','pdf');
    xshist = (ehist(2:end)+ehist(1:end-1))/2;
    yspdf = theopdffunx(xshist);
    sqd = sum((yspdf - yshist).^2);

end