function [reject,stat,thresh] = NormGof(x,mu,sigma,modelnotfromdata)
% Does a GOF hypothesis test of the given model to explain DS.
% MODELNOTFROMDATA == 1 indicates that the model does not come from the
% data (usually it is the true model generating the data); == 0 indicates
% that the model has been fitted on the same data.

    NormCheckParms(mu,sigma);

    n = numel(x);
    x = reshape(x,1,n); % force X is a row vector

    % we reuse here part of the LognormalGof, since they are analogous.

    w = (x - mu) / sigma; % now normal(0,1)
    Z = normcdf(w,0,1); 

    [kindstat,stat] = StatisticGof(Z);
    if strcmp(kindstat,'W2')

        if modelnotfromdata
            % correction if parms are true (not from sample); table 4.2
            % D'Agostino
            stat = (stat - 0.4/n + 0.6/n^2) * (1 + 1/n);
            thresh = 0.461;  
        else % model comes from data
            % the following is D'Agostino table 4.7, upper tail
            stat = stat * (1 + 0.5/n);

            % This is from D'Agostino; it does not work exactly in our case
            % (tested with test_significanceofgofs.m), probably because our
            % normal samples never have negative values.
            %thresh = 0.117;
            % The one working for us (test_tabulate...) is:
            thresh = 0.126;

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
