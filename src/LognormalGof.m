function [reject,stat,thresh] = LognormalGof(x,offset,mu,sigma,modelnotfromdata,mode)
% MODE -> same as in LognormalFit()


    LognormalCheckParms(offset,mu,sigma);

    n = numel(x);
    x = reshape(x,1,n); % force X is a row vector

	% Based on D'Agostino p. 122

    logx = log(x - offset); % still ordered, now unshifted and normal
    w = (logx - mu) / sigma; % now normal(0,1)
    Z = normcdf(w,0,1); % cdf formula for the normal

    [kindstat,stat] = StatisticGof(Z);
    if strcmp(kindstat,'W2')

        if modelnotfromdata
            % correction if parms are true (not from sample); table 4.2
            % D'Agostino
            stat = (stat - 0.4/n + 0.6/n^2) * (1 + 1/n);
            thresh = 0.461;  % we have confirmed this value with MonteCarlo (test_tabulategofthrs.m)
        else % model comes from data
            % the following is D'Agostino table 4.7, upper tail
            stat = stat * (1 + 0.5/n);

            if strcmp(mode,'cohen-momentsforcefit-normal')
                                
                % the following is for the unbiased moments, no std bug, no shiftcorrection
                endspartsss = [90,10000];
                coeffs1 = [-2.90535607380687e-07	6.69820112318446e-05	-0.00505402498700543	0.292511302536082];
                funpart1 = @(ss) polyval(coeffs1,ss);
                coeffs2 = [2.38843364726652e-16	-4.27021537891446e-12	2.52914852901848e-08	0.000109960128411184	0.159633019035599];
                funpart2 = @(ss) polyval(coeffs2,ss);
                funparts = {funpart1,funpart2};
                kperc = 0.8;

                [thresh,~] = weld_functions(funparts,endspartsss,kperc,n);
                
            else
                error('Unimplemented mode in lognormal gof');
            end               


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
