function [ok, offs, mu, sigma, casesign] = LognormalFit(x,mode,trace)
% Fit through MLE a 3-lognormal to the data in X.
% 
% We estimate the offset and then fit a non-shifted lognormal. A positive 
% random variable X is lognormally distributed if the natural logarithm of 
% X is normally distributed.
%
% pdf(x) = 1/((x - offs) * sigma * sqrt(2*pi)) * exp(-( (log(x - offs) - mu)^2/(2*sigma^2) ))
% Expectation: offset + exp(mu + sigma^2 / 2); median: exp(mu); mode: offset + exp(mu - sigma^2); variance: exp(sigma^2) - 1) * exp(2*mu + sigma^2)
%
% Ours, wikipedia and Matlab use the same formulation.
% A lognormal sample cannot have any value <= to its offset. The offset
% estimation procedure deals correctly with such values.
%
% X -> data sample, with min(x) > 0.
% MODE -> mode of estimation (DO NOT CHANGE THESE NAMES; THE START MUST BE
%                             COHEN or COHENII FOR CORRECT WORKING):
%           'cohen-momentsforcefit-normal' -> same as
%                                             'cohen-moments-normal' but
%                                             allows for considering
%                                             estimated offsets through the
%                                             method of moments when its
%                                             non-linear optimization
%                                             exceeds the max num of iters.
%                                             This almost always guarantees
%                                             a fit and seems to provide 
%                                             good models (power) too.
%
% OK <- 1 indicating a fit is found, always.
% OFFS <- offset in the data, >= 0 and < min(x).
% MU <- mean of the natural logarithm of the non-shifted data.
% SIGMA <- std of the natural logarithm of the non-shifted data.
% CASESIGN <- for debugging (see estimateOffset() below).

global TOLROUNDTRIPS

    ConstantsInit();

    ok = 0;
    offs = NaN;
    mu = NaN;
    sigma = NaN;
    casesign = NaN;

    if ~SampleIsValid(x)
        return; 
    end

    [ok,offs,casesign] = estimateOffset(x,mode,trace); % ok < 3 if Cohen failed
    if ~ok
        return;
    end

    % Given offset, these are the MLE for mu and sigma according to
    % wikipedia (both unbiased):
    %  mu = sum(log(xi - offs)) / n
    %  sigma = sqrt(  sum((log(xi - offs) - mu)^2) / (n - 1) )
    
    ds = log(x - offs); % reduce to non-shifted normal
    mu = mean(ds); % estimate mu and sigma as the ones of that normal (MLE)
    sigma = std(ds);

    ok = 1;

end

function [ok,offset,casesign] = estimateOffset(reg,mode,trace)
% MLE estimation of the lognormal offset of the sample REG; when there is
% no solution in the MLE formula, a heuristic estimation is done.
%
% REG -> sample
% MODE -> as in LognormalFit()
% TRACE -> 0 to not trace; 1 to trace console; 2 to trace figs besides
% 
% OK <- 1 if the offset has been estimated heuristically at one of the extremes
%       because the zero-crossing function did not changed its sign at those
%       extremes; 
%       2 if it has been estimated at one of the extremes because
%       the search for it in between has failed; 
%       3 if it has been estimated
%       correctly within the possible range and was unique; 
%       4 in the same
%       situation but has been selected among all the offsets found.
%       0 if the offset cannot be estimated.
% OFFSET <- offset estimated for the data.
% CASESIGN <- 0 if different signs and zero crossing found.
%             1 for the case the signs of the zero-crossing function have
%             the same sign in both extremes and the result is
%             gaussian-like.
%             2 is like 1 but exponential-like.          

global TOLROUNDTRIPS

    ConstantsInit();

    ok = 0;
    offset = NaN;
    casesign = NaN;

    % --------- DATA SANITIZING

    correctionoffset = 0;
    correctedsample = reg;
    minreg = min(reg);
    if trace
        fprintf('-------- reg[%f,%f] mean(%f) median(%f) mean/median(%f) CORRECTION %f \n',...
                min(correctedsample),max(correctedsample),mean(correctedsample),median(correctedsample),mean(correctedsample)/median(correctedsample),correctionoffset);
    end
    orderedsample = sort(correctedsample);
    
    % ------ COHEN'S ZERO-CROSSING FUNCTION THAT ESTIMATES THE OFFSET WITH MLE

	r = 1;
    n = length(orderedsample);
    kr = norminv(r/(n+1)); 
    
    if trace == 2
        gxs = linspace(orderedsample(r)-10,orderedsample(r)-TOLROUNDTRIPS,1000000);
        gys = zeros(1,length(gxs));
        for f = 1:length(gys)
            gys(f) = MMLEIfun(orderedsample,gxs(f),r,kr,n);
        end
        hfig = figure;
        plot(gxs,gys,'r.-');
        hold on;
        grid;
        plot(gxs,zeros(1,length(gxs)),'k-','LineWidth',1);
        title(sprintf('Cohen fun (3rd central moment = %f, x(1) = %f)',moment(correctedsample,3),orderedsample(1)));
        drawnow;
    end            
    
    if startsWith(mode,'cohenII')
        funtofindzeroes = @(g) MMLEIIfun(orderedsample,g,n);
    else
        funtofindzeroes = @(g) MMLEIfun(orderedsample,g,r,kr,n); 
    end
    x0 = [TOLROUNDTRIPS, ...
          orderedsample(r) - TOLROUNDTRIPS];
        % Range of search for G
        
    % ---------- EXAMINE ZERO-CROSSING FUNCTION BEFORE USING IT

    f0 = funtofindzeroes(x0(1));
    f1 = funtofindzeroes(x0(end));
    if sign(f0) == sign(f1) % Cannot do the search

        if trace
            fprintf('signs the same\n');
        end
        if trace == 2
            gxs = linspace(TOLROUNDTRIPS,orderedsample(1),1000000);
            gys = zeros(1,length(gxs));
            for f = 1:length(gys)
                gys(f) = funtofindzeroes(gxs(f));
            end
            hfig = figure;
            subplot(1,2,1);
            plot(gxs,gys,'r.-');        
            hold on;
            grid;
            plot(gxs,zeros(1,length(gxs)),'k-','LineWidth',1);
            plot(orderedsample(1)*[1 1],[min(gys),max(gys)],'k-');
            title('Zero-crossing function');
            subplot(1,2,2);
            histogram(orderedsample);
            grid;
            title('Shifted sample histogram');
            drawnow;
        end

        if strcmp(mode,'cohen-momentsforcefit-normal')

            casesign = 2;

            [ok,offset,~,~] = methodofmoments(orderedsample,TOLROUNDTRIPS,strcmp(mode,'cohen-momentsforcefit-normal'));
            % we just take offset; mu and sigma are better estimated not
            % by the method of moments (otherwise, power goes down because of the bad estimation)
            if ok
                offset = offset + correctionoffset;
                if offset >= minreg
                    offset = minreg - TOLROUNDTRIPS;
                end
                % we just take offset; mu and sigma are better estimated not
                % by the method of moments (otherwise, power goes down because of the bad estimation)
            else
                ok = 0;
                return;
            end

        else
            error('Unknown mode of offset estimate for LN3');
        end

    else % there is a change of sign in function, thus some possible zero crossing

        casesign = 0;

        if trace
            fprintf('signs different ok %d\n',ok);
        end        
        if trace == 2
    
            gxs = linspace(TOLROUNDTRIPS,orderedsample(1),1000000);
            gys = zeros(1,length(gxs));
            for f = 1:length(gys)
                gys(f) = funtofindzeroes(gxs(f));
            end
            hfig = figure;
            subplot(1,2,1);
            plot(gxs,gys,'r.-');
            hold on;
            grid;
            plot(gxs,zeros(1,length(gxs)),'k-','LineWidth',1);
            plot(orderedsample(1)*[1 1],[min(gys),max(gys)],'k-');
            title('Zero-crossing function');
            subplot(1,2,2);
            histogram(orderedsample);
            grid;
            title('Shifted sample histogram');
            drawnow;
        end
        
        % Finding zero
        options = optimset('Algorithm', 'levenberg-marquardt'); %'LevenbergMarquardt', 'on');  
        try
            [offsets,fval,exitflag,output] = fzero(funtofindzeroes, x0, options);
            offsets = offsets(isreal(offsets) & (offsets < orderedsample(1)));
            numsols = length(offsets);
            if numsols == 0
               error('Change of signs in Cohen but error in fzero');
            else
                if numsols > 1 % several solutions: cohen chooses the one giving expectation closest to sample mean
                   mu = zeros(1,numsols);
                   s = zeros(1,numsols);
                   for i = 1:lnumsols
                        p = lognfit(orderedsample - offsets(i));
                        mu(i) = p(1);	% mu parameter 2params LN
                        s(i) = p(2);
                   end
                   esperanzas = offsets + exp(mu+(s.^2)./2);	% expectation of the LLN3 (cohen first page)
                   sm = mean(orderedsample); % sample mean

                   erresps = (esperanzas - sm).^2;
                   [~,in] = min(erresps);
                   offset = offsets(in);
                   ok = 4;
                else
                   offset = offsets(1);
                   ok = 3;
                end
            end
            if isnan(offset)
                error('nan offset');
            end
            offset = offset + correctionoffset;
        catch errRecord    
            disp(errRecord);
            error('exception in fzero');
        end
    
    end

    if (offset < 0) || (offset >= minreg)
        error('Invalid offset calculation');
    end
    
end

function [ok,offset,mu,sigma] = methodofmoments(sample,tole,withexceedediters)
% Calculate the parameters of LN3 through the method of moments.
%
% SAMPLE -> sample
% TOLE -> tolerance for both the non-linear optimization and the offset
%         tolerance w.r.t. min(sample).
% WITHEXCEEDEDITERS -> 1 to yield a result even when the non-linear
%                      optimization reaches the max num of iterations.
%
% OK <- 0 if failed, 1 if not.
% OFFSET,MU,SIGMA <- parameters or NaN if failed. NOTE: Offset may coincide
% with the minimum of the sample due to numerical errors, and that is not
% corrected here.

    ok = 0;
    offset = NaN;
    mu = NaN;
    sigma = NaN;

    n = length(sample);
    
    m1 = sum(sample) / n; % mu_x. unbiased
    m2 = 1 / (n - 1) * sum((sample - m1).^2);  % sigma_x^2, unbiased
    m3 = n / ((n - 1) * (n - 2)) * sum((sample - m1).^3); % G_x, unbiased    
  
    % function to minimize
    fun1 = @(gamma,mu,sigma) gamma + exp(mu + 1/2*sigma*sigma) - m1;
    fun2 = @(gamma,mu,sigma) exp(2*mu + sigma*sigma)*(exp(sigma*sigma) - 1) - m2;
    fun3 = @(gamma,mu,sigma) exp(3*mu + 3/2*sigma*sigma)*(exp(sigma*sigma) - 1)*(exp(sigma*sigma) + 2) - m3;
    fun = @(x) [fun1(x(1),x(2),x(3)); fun2(x(1),x(2),x(3)); fun3(x(1),x(2),x(3))];
    % initial value
    miny = min(sample);
    gamma0 = miny - tole;
    w = log(sample - gamma0);
    mu0 = mean(w); 
    sigma0 = std(w);
    x0 = [gamma0;mu0;sigma0];
    % optimization
    lb = [tole;-Inf;eps];
    ub = [miny - eps;Inf;Inf];
    options = optimset('Display', 'off', 'Algorithm', 'trust-region-reflective', 'Jacobian', 'off', 'TolFun', tole, 'TolX', tole);
    thereismomsopt = 0;
    try
        [xx,~,~,exitflag,~] = lsqnonlin(fun,x0,lb,ub,options);
        if (exitflag > 0) || ...
           (withexceedediters && (exitflag == 0))
            thereismomsopt = 1;
        end
    catch        
    end

    if thereismomsopt
        offset = xx(1);
        mu = xx(2);
        sigma = xx(3);
        ok = 1;
    end

end

function ga = MMLEIfun(orderedsample,gamma,r,kr,n)
% Modified function of Cohen, used here

    lsg = log(orderedsample-gamma);
    sg = sum(lsg);
    ga = log(orderedsample(r)-gamma) - sg/n - kr*sqrt( sum(lsg.*lsg)/n-(sg/n).^2 );
    if ~isreal(ga) % may occur due to the numerical noise
        ga = real(ga); % gives better results than Inf in quality of models
    end
    
end

