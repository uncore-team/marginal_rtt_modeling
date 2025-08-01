function [reject,stat,thresh]=LoglogisticGoF(x,a,b,c,modelnotfromdata)
% Anderson-Darling test the goodness of fit of the 3-loglogistic (A,B,C) for 
% the sample XS.
%
% modelnotfromdata -> 1 if the parameters do not come from sample; 0 if they have
%                  been calculated from the same sample.
%
% REJECT <- 1 if we have to reject the null hypothesis that the model
%           explains the sample, 0 if we cannot say if it explain the sample
%			or not (and therefore we might assume the model is correct).
% STAT <- value of the statistic for that sample (the smaller, the better)
% THRESH <- value below which the statistic should have been in order not
%           to reject the null hypothesis with the 5% significance level, i.e.,
%			in order to assume the LL3 model fits well the data. In case of non-
%			rejection, STAT will be in [0,THRESH], thus it can be normalized to
%			[0,1] in order to get a "degree of non-rejection" (less rejection as
%			smaller is that degree); this works as an alternative to the p-value
%			that is safe to use as long as we do not assume any linearity or
%			other particular decreasing profile in STAT.

    LoglogisticCheckParms(a,b,c);

    n = numel(x);
    x = reshape(x,1,n); % force X is a row vector

    % ---- transform sample to LL2 (0 offset) and model (a,b,c) into Matlab model (mu,sigma)
    xL = log(x - a); % de-shift and de-exp
    mu = log(b); % converting from a,b,c to D'Agostino (alpha in the book), which uses the same as Matlab
    s = c; % converting from a,b,c to D'Agostino (beta in the book), which uses the same as Matlab

    % ---- calculate a new random variable Z (p. 160) that has uniform distribution in [0,1]
    % if the theoretical model (mu,sigma) is true (p. 101)
    Z = 1./(1 + exp(-(xL-mu)./s)); % cdf formula for a common logistic

    % ---- calculate statistic: A2 
    [kindstat,stat]  = StatisticGof(Z);
    if strcmp(kindstat,'W2')

        if modelnotfromdata
            % correction if parms are true (not from sample); table 4.2
            % D'Agostino
            stat = (stat - 0.4/n + 0.6/n^2) * (1 + 1/n);
            thresh = 0.461; % we have confirmed this value with MonteCarlo (test_tabulategofthrs.m)
        else % model comes from data
            
            % % the following is D'Agostino table 4.22 and does not work for
            % % us, probably because D'Agostino uses Logistic, not
            % % log-logistic
            stat = (n * stat - 0.08) / (n - 1);

            % Montecarlo offset expo, no shiftcorr
            endspartsss = [1350,5200,10000];
            coeffs1 = [8.47597347304412e-21	-4.65037090157405e-17	1.05107424918927e-13	-1.26680627065562e-10	8.80469214105822e-08	-3.57199125291626e-05	0.00830307365245381	0.00800871978972110];
            funpart1 = @(ss) polyval(coeffs1,ss);
            coeffs2 = [1.54472346524334e-08	-6.97828989559281e-05	1.10545573474545];
            funpart2 = @(ss) polyval(coeffs2,ss);
            coeffs3 = [7.35465529012554e-05	0.760657621075085];
            funpart3 = @(ss) polyval(coeffs3,ss);
            funparts = {funpart1,funpart2,funpart3};
            kperc = 0.999;

            [thresh,~] = weld_functions(funparts,endspartsss,kperc,n);

        end

    else
        error('Unknown gof statistic');
    end

    if (stat > thresh) % equivalently, the p-value is smaller than the significant level
        reject=1; % reject
    else
        reject=0; % cannot reject the null hypothesis that the data come from a LL3
    end 

end
