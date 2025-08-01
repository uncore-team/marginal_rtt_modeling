function [reject,stat,thresh] = ExponentialGof(x,alpha,beta,modelnotfromdata)
% Based on D'Agostino p. 141: both parameters unknown. 
% See ExponentialFit()

    ExponentialCheckParms(alpha,beta);

    n = numel(x);
    x = reshape(x,1,n); % force X is a row vector

	% ---- transform sample to a theoretically uniform one (not sorted)

    w = (x - alpha) / beta;
    Z = 1 - exp(-w); % cdf for a common exponential

    % ---- calculate EDF statistic
    [kindstat,stat] = StatisticGof(Z);
    if strcmp(kindstat,'W2')

        if modelnotfromdata
            % correction if parms are true (not from sample); table 4.2
            % D'Agostino
            stat = (stat - 0.4/n + 0.6/n^2) * (1 + 1/n);
            thresh = 0.461; % we have confirmed this value with MonteCarlo (test_tabulategofthrs.m)
        else % model comes from data
            % correction if parms come from sample; table 4.14 D'Agostino
            stat = stat * (1 + 2.8/n - 3/n^2);
            thresh = 0.222; % we have confirmed this value with MonteCarlo (test_tabulategofthrs.m)
        end

    else
        error('Unknown gof statistic');
    end

    if (stat > thresh) % equivalently, the p-value is smaller than the significant level
        reject=1; % reject
    else
        reject=0; % cannot reject the null hypothesis of the data coming from an exponential
    end 

end
