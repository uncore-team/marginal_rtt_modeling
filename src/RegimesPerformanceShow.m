function RegimesPerformanceShow(regperfs,tit)
% Show the performance metrics stored in REGPERFS (see RegimesPerformance)
%
% REGSPERFS -> a cell like the one returned by RegimePerformance.

    n = length(regperfs);
    if n == 0
        return;
    end
    
    ca = ExperimentCatalog(0);
    bxpdata = [];
    bxpgrps = {};
    bxtimes = [];
    bxtimesgrps = {};
    bxexctimes = [];
    bxexctimesgrps = {};
    bxbatches = [];
    bxbatchesgrps = {};
    scnexpl = zeros(1,n);
    bxsqd = [];
    bxsqdgrps = {};
    for f = 1:n % for each scenario
        regperf = regperfs{f};
        % perc. expl.
        scnexpl(f) = regperf.numexpl / regperf.scnlen;
        % reglens
        if regperf.numregs > 0
            for g = 1:regperf.numregs % for each regime in the scenario
                bxpdata = [bxpdata ; regperf.reglens(g)];
                bxpgrps{length(bxpgrps)+1} = regperf.scnname;
            end
        else
            bxpdata = [bxpdata ; 0];
            bxpgrps{length(bxpgrps)+1} = regperf.scnname;
        end
        % comptimes - for each comp time measured
        for g = 1:length(regperf.comptimes)
            bxtimes = [bxtimes ; regperf.comptimes(g)];
            bxtimesgrps{length(bxtimesgrps)+1} = regperf.scnname;
        end
        % excesstimes - for each excesstime measured
        for g = 1:length(regperf.excesstimes)
            bxexctimes = [bxexctimes ; regperf.excesstimes(g)];
            bxexctimesgrps{length(bxexctimesgrps)+1} = regperf.scnname;
        end
        % batchneeded - for each batchneeded calculated
        for g = 1:length(regperf.batchneeded)
            bxbatches = [bxbatches ; regperf.batchneeded(g)];
            bxbatchesgrps{length(bxbatchesgrps)+1} = regperf.scnname;
        end
        % square distances
        if regperf.numregs > 0
            for g = 1:regperf.numregs % for each regime in the scenario
                bxsqd = [bxsqd ; regperf.sqds(g)];
                bxsqdgrps{length(bxsqdgrps)+1} = regperf.scnname;
            end
        end
    end

    figure;
    hold on;
    h = boxplot(bxpdata,bxpgrps); %,'PlotStyle','compact');
    grid;
    ylabel('Reg. Len. (# RTTs)');
    title(sprintf('%s - regime length',tit));
    set(findobj(h, 'Type', 'Line'), 'LineWidth', 2);
    set(gca, 'YScale', 'log');
    yyaxis right;
    plot(scnexpl,'x','MarkerSize',18,'LineWidth',2);
    ylabel('% explained');

    figure;
    plot(scnexpl,'.','MarkerSize',12);
    grid;
    xticks(1:n);
    ylabel('Scn. expl. (%)');
    title(sprintf('%s - %% explained',tit));

    figure;
    h = boxplot(bxtimes,bxtimesgrps); %,'PlotStyle','compact');
    grid;
    ylabel('Comp. time (s)');
    title(sprintf('%s - computation time',tit));
    set(findobj(h, 'Type', 'Line'), 'LineWidth', 2);
    set(gca, 'YScale', 'log');

    figure;
    histogram(bxtimes,100);
    grid;
    xlabel('time (s)');
    ylabel('count');
    notnants = bxtimes(~isnan(bxtimes));
    title(sprintf('%s - mode = %f, median =%f, \\mu = %f, \\sigma = %f',...
                  tit,mode(notnants),median(notnants),mean(notnants),std(notnants)));

    figure;
    h = boxplot(bxexctimes,bxexctimesgrps);
    grid;
    ylabel('Excess time (s)');
    title(sprintf('%s - excess time',tit));
    set(findobj(h, 'Type', 'Line'), 'LineWidth', 2);
    %set(gca, 'YScale', 'log');
    fprintf('%d data with excess time < 0\n',length(find(bxexctimes < 0)));
    fprintf('%d data with excess time > 0\n',length(find(bxexctimes > 0)));
    fprintf('%d data with excess time = 0\n',length(find(bxexctimes == 0)));

    figure;
    h = boxplot(bxbatches,bxbatchesgrps);
    grid;
    ylabel('Batch needed (# RTTs)');
    title(sprintf('%s - batch needed',tit));
    set(findobj(h, 'Type', 'Line'), 'LineWidth', 2);
    set(gca, 'YScale', 'log');

    figure;
    h = boxplot(bxsqd,bxsqdgrps);
    grid;
    ylabel('dist. (density)');
    title(sprintf('%s - squared distances',tit));
    set(findobj(h, 'Type', 'Line'), 'LineWidth', 2);
%    set(gca, 'YScale', 'log');
    
end