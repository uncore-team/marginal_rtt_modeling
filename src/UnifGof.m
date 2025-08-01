function [reject,stat,thresh] = UnifGof(x,a,b,modelnotfromdata)
% Does a GOF hypothesis test of the given model to explain X.
% MODELNOTFROMDATA == 1 indicates that the model does not come from the
% data (usually it is the true model generating the data); == 0 indicates
% that the model has been fitted on the same data.

    UnifCheckParms(a,b);

    n = numel(x);
    x = reshape(x,1,n); % force X is a row vector    
    reject = 0;
    stat = NaN;
    thresh = NaN;
    if n <= 2
        return; % cannot work with so little data
    end

    % ---- transform the allegedly uniform data into UNIF(0,1)
    xsort = sort(x); % needed for the next "if"
    u = (xsort - a) / (b - a);
    if ~modelnotfromdata
        % we drop the 2 largest values as explained in D'Agostino p.360
        % option a) and go on with a parms not-from-sample test
        u = u(1:end - 2);
    end
    Z = u; % cdf for UNIF(x;0,1) = (x - a) / (b - a) = (x - 0) / (1 - 0) = x

    % ---- calculate EDF statistic for case 0 (both parms not from sample)
    [kindstat,stat] = StatisticGof(Z);
    if strcmp(kindstat,'W2')

        % correction if parms are true (not from sample); table 4.2
        % D'Agostino
        stat = (stat - 0.4/n + 0.6/n^2) * (1 + 1/n);
        % threshold confirmed with MonteCarlo (test_significanceofgofs...)
        thresh = 0.461; 

    else
        error('Unknown gof statistic');
    end

    if (stat > thresh) % equivalently, the p-value is smaller than the significant level
        reject=1; % reject
    else
        reject=0; % cannot reject the null hypothesis of the data coming from an exponential
    end 
    

end