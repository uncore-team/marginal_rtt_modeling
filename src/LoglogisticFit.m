function [a, b, c, exitflag] = LoglogisticFit(ds)
% Fit through MLE a 3-loglogistic to the data in DS
%
% EXITFLAG <- the exitflag of the last optimization call if it is incorrect
% that is, <0 (then, parameters a,b,c are filled with initial guesses). If
% exitflag is >= 0, the model can be considered acceptable, even if it is 0
% (too many iterations)

global TOLROUNDTRIPS

    ConstantsInit();

    a = NaN;
    b = NaN;
    c = NaN;
    exitflag = -100;

    if ~SampleIsValid(ds)
        return; 
    end

    minds=min(ds);
    correctionoffset = 0;
    x = ds; % no shift correction

    n = length(x);
    minx = min(x);
    maxx = max(x);
    mux = mean(x);

    tole=TOLROUNDTRIPS;
	optimalg='trust-region-reflective'; 
	minc=0.05;
	maxc=1/2-eps; % c<1 for having expectation; c<1/2 for having variance
    debug=0;
    
    % initial guess for "a"
    
    [ahat,~] = ExponentialOffset(x);
    if ahat >= minx
        ahat = minx - TOLROUNDTRIPS;
    end
    
    % initial guess for b
    bhat = median(x-ahat);
    if (bhat < 1e-6)
        bhat = 1e-6; % to avoid some numerical errors in the fitting pass
    end

	% initial guess for c, given those initial a and b
    options=optimset('Display', 'off', 'Algorithm', optimalg,'TolFun', tole, 'TolX', tole); 
    boundmin=[minc];
    boundmax=[maxc]; 
	c0=minc;
    chat = NaN;

    exitflag = -1000;
    try
        [chat,RESNORM,RESIDUAL,exitflag,OUTPUT] = lsqnonlin(@(chat) ahat + bhat*beta(1+chat, 1-chat) - mux,c0,...
                                                            boundmin,boundmax,options);
    catch E
        exitflag = -200;
        return
    end
    a=ahat;
    b=bhat;
    c=chat;    
    if (exitflag<0)
        return;
    end

    % do the fitting of the entire loglogistic from that seed
    x0 = [ahat; bhat; chat]; % start at initial guess
    options=optimset('Display', 'off', 'Algorithm', optimalg, 'Jacobian', 'on', 'TolFun', tole, 'TolX', tole);%, 'Display','iter');
    lb = [eps; eps; minc]; 
    ub = [minx-TOLROUNDTRIPS; inf; maxc];     
    xx = nan(3,1);
    exitflag = -1000;
    try
        [xx,RESNORM,RESIDUAL,exitflag,OUTPUT] = lsqnonlin(@(x0) Loglogistic_fittingfunctions(x0,x,n), x0,lb,ub,options);
    catch E
        if strcmp(E.identifier,'optimlib:commonMsgs:UserJacUndefAtX0') % jacobian undefined at the first step; try without jacobian
            options = optimset(options, 'Jacobian', 'off');
            try
                [xx,RESNORM,RESIDUAL,exitflag,OUTPUT] = lsqnonlin(@(x0) Loglogistic_fittingfunctions(x0,x,n), x0,lb,ub,options);
            catch E
                exitflag = -300;
                return;
            end
        end
    end
    if (exitflag<0)
        return;
    end
    a = xx(1) + correctionoffset; % recover the original unshifted data
    b = xx(2);
    c = xx(3);
    
    % assure the LL3 is valid (see LoglogisticIsValid())

    if (a<=0.0) 
        if (debug==1)
            fprintf('A!');
        end
        a=TOLROUNDTRIPS;
    end
    if (a>=minds) 
        if (debug==1)
            fprintf('M!');
        end
        a=minds-TOLROUNDTRIPS;
    end
    if (b<=0.0) 
        if (debug==1)
            fprintf('B!');
        end
        b=TOLROUNDTRIPS;
    end
    if (c<=0.0) 
        if (debug==1)
            fprintf('C!');
        end
        c=TOLROUNDTRIPS;
    end

end