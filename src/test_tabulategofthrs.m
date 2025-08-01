% Tabulate the threshold for the GoF experimentally for different sample
% sizes.

% NOTE: To reduce the heat and consumption of the computer, if it has 24
% cores, being 16-23 of non-high performance, we can force in linux to use
% them only this way: taskset -c 16-23 /APLICACIONES/Matlab2023b/bin/matlab
% And them limit to 8 the number of cores to use in matlab with: maxNumCompThreads(8)

% @varevalo Adapted for parallelization & sending notifications

clc;
% clear; % commeted by recovering purposes
close all;

%rng(54);

% model to tabulate and general experiment parms
mtrue = ModelCreate('EXP2'); % set here the distribution to work with: EXP2, LN3 or LL3
parmsunknown = 1; % 1 - tabulate for unknown parameters that are deduced from the sample; 2- same except the offset; 0 - tabulate for the true params that generate the sample
samplesizes = [20:10:2000, 2100:100:10000]; % 5000 [20:10:500]; %510:10:1000; % samples sizes to tabulate
numtests = 10000; % monte carlo simulation on that number of samples
alpha = 0.05; % significance level to tabulate for

% --- do not touch the code from here on

datetime_start = datetime('now'); % notify info
text_notification = [mtrue.type ' onemarginal'];

% internal parms that should not be changed
traceinternal = parmsunknown;
usesimplerinterp = 1; % 1 == adjust better to the thresholds in D'Agostino for known parms and produces more coherent results when tested with test_significanceofgof.m

measurements = cell(1,length(samplesizes));
results = nan(1,length(samplesizes));
if parmsunknown
    if parmsunknown == 2
        nametrace = sprintf('%s (parms from sample except offset)',mtrue.type);
    else
        nametrace = sprintf('%s (parms from sample)',mtrue.type);
    end
else
    nametrace = sprintf('%s (parms true)',mtrue.type);
end
t0ext = tic;
for f = 1:length(samplesizes)
    samplesize = samplesizes(f);
    fprintf('TABULATING %s for size %d... ',nametrace,samplesize);
    toc(t0ext)

    stats = nan(1,numtests);
    parfor t = 1:numtests
        % if traceinternal
	    %     progress(t,numtests,'\t','t_in_testtabulategofthrs',1);
        % end
        % force to obtain results for all numtests:
        finish = 0;
        while ~finish
            mo = ModelCreateRnd(mtrue.type,'typrnd'); % create the true params for the model (randomly)
            ds = ModelRnd(mo,1,samplesize); % draw a sample of the given size
            if parmsunknown
                mfit = ModelFit(ds,1,length(ds),mtrue.type); % fit a model to the sample
                if ~mfit.defined
                    continue; % get another sample if fit fails
                end
                if (parmsunknown == 2) && ModelHasOffset(mtrue.type)
                    mfitcoeffs = ModelToCoeffs(mfit);
                    mtruecoeffs = ModelToCoeffs(mo);
                    mfitcoeffs(2) = mtruecoeffs(2);
                    mfit = ModelFromCoeffs(mfitcoeffs);
                end
                [~,stat,thresh] = ModelGof(mfit,ds,0); % get the statistic for that fitting
                if isinf(stat) || isnan(thresh)
                    continue; % get another sample if gof fails
                end
            else
                %nm = ModelAdjustForSample(mo,ds);
                [~,stat,thresh] = ModelGof(mo,ds,1); % get the statistic for the true parms
                if isinf(stat) || isnan(thresh)
                    continue; % get another sample if gof fails after fit
                end
            end
            stats(t) = stat;
            finish = 1;
        end
    end

    measurements{f} = stats;
    if traceinternal
        fprintf('\t\t');
    end
    results(f) = deducethresholdfromstatsquantile(stats,alpha,traceinternal);
    
end

namefi = sprintf('matlab_tabulatethresgof_%s',mtrue.type);
if parmsunknown
    if parmsunknown == 2
        namefi = sprintf('%s_parmsfromsampleexceptoffset',namefi);
    else
        namefi = sprintf('%s_parmsfromsample',namefi);
    end
else
    namefi = sprintf('%s_parmstrue',namefi);
end
res_filename = sprintf('%s_%d_to_%d.mat',namefi,samplesizes(1),samplesizes(end));
save(res_filename);

gong();
notify('varevalo@uma.es','[test_tabulategofthrs.m] Experiment finished', ...
       ['Experiment started: ' char(datetime_start) newline...
        'Experiment finished: ' char(datetime('now')) newline ...
        'Experiment duration: ' char(datetime('now') - datetime_start) newline ...
        'Results saved in: ' res_filename newline ...
        text_notification newline]);

return;

%% This section loads the file created by the first section and display the results

load('your file.mat');

figure;
plot(samplesizes,results,'b.','MarkerSize',24);
hold on;
grid;
xlabel('sample size');
ylabel('\tau_\alpha');

figure;
drawHisto(results,'histogram','threshold for gof');

return;

%% AUXILIARY FUNCTIONS

function threshold = deducethresholdfromstatsquantile(stats,alpha,traceinternal)
% Deduce the threshold counting the stats from smallest to largest (more
% robust than from largest to smallest), until reaching 1-alpha area.
% This method is called "Empirical Quantile estimation", being the quantile
% 0.95 in the case that alpha == 0.05.

    threshold = quantile(stats,1-alpha);

    % % theoretically equivalent to the following, but matlab also
    % % interpolates to reach the eact point:
    % 
    % ntotstats = length(stats);
    % if ntotstats <= 1
    %     error('Cannot find threshold with <= 1 stats');
    % end
    % 
    % % number of stats needed to represent 1-alpha proportion:
    % countforminusalpha = round((1 - alpha) * ntotstats);
    % if (countforminusalpha <= 0) || (countforminusalpha >= ntotstats)
    %     error('Cannot find threshold with invalid countforminusalpha');
    % end
    % 
    % sortstats = sort(stats);
    % threshold = sortstats(countforminusalpha + 1); % first stat that goes to alpha proportion
    % if traceinternal
    %     fprintf('Threshold: %f; countminusalpha: %d; total: %d; indexfirstalpha: %d\n',...
    %             threshold,countforminusalpha,ntotstats,countforminusalpha + 1);
    % end
    
    if traceinternal
        fprintf('Threshold: %.15f\n',threshold);
    end
    
end
