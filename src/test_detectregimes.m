% test of detection of regimes

% @varevalo Adapted for sending notifications

clc;
% clear; % commeted by recovering purposes
close all;

% --- write down here the name of the distribution to use for detecting regimes (EXP2, LN3, LL3)

distname = 'EXP2';

% --- set the maximum number of RTTs to use in the scenario (or Inf for all)

maxdatatouse = 5000;


% --- do not touch from this point on


% onemarginal regime detection:
mode = 'onemarginal';
parms = struct('distrib',distname,...
               'minlen',20);

datetime_start = datetime('now'); % notify info
text_notification = [parms.distrib ',' mode];

ca = ExperimentCatalog(0);
transformintorobotdistance = 0; % 1-> to transform rtts into the distance travelled by a robot that exhibits those rtts and moves with certain speed 
robotspeed = 0.25; % in m/s

allregs = {};
allts = {};
for exind = 1:length(ca)

    fprintf('\n\n===> EXPERIMENT #%d: [%s:%d] %s, dens %d, net %s, dist %s, serv %s, cli %s\n',...
        exind,ca{exind}.class,ca{exind}.index,ca{exind}.name,...
        ca{exind}.dens,ca{exind}.netw,ca{exind}.dist,ca{exind}.serversw,ca{exind}.clientsw);

    fprintf('\tLoading...\n');
    [fdir,fexp,historial] = ExperimentGet(ca,ca{exind}.class,ca{exind}.index,1,Inf,0,0,0);

    % --- Do the detection
    
    regs = [];
    if length(historial) > maxdatatouse
        fprintf('Data loaded and truncated for regime detection.\n');
        historial = historial(1:maxdatatouse);
    else
        fprintf('Data loaded with %d roundtrip times.\n',length(historial));
    end
    if transformintorobotdistance
        units = 'meters';
    else
        units = 'millisecs';
    end
    
    [regs,ts] = RegimeDetection(historial,mode,parms,1);
    fprintf('%d regimes detected.\n',size(regs,1));
    sumtot = length(historial);
    sumexpl = zeros(1,sumtot);
    maxlenreg = 0;
    for f = 1:size(regs,1)
        sumexpl(regs(f,1):regs(f,2)) = 1; % some regimes may overlap others (if sample sliding)
        l = regs(f,2)-regs(f,1)+1;
        if l > maxlenreg
            maxlenreg = l;
        end
    end
    sumexpl = sum(sumexpl);
    fprintf('%d explained out of %d vs %d not explained (%.2f%% explained)\n',sumexpl,sumtot,sumtot-sumexpl,sumexpl/sumtot*100);
    fprintf('Max reg len: %d\n',maxlenreg);
    if strcmp(mode,'onlineransac')
        tit = sprintf('%s; modeltypes:%d; modelpreserv:%d; sliding:%d; datapreserv:%d',...
                      fexp,...
                      length(onlineransacparms.mtypes),...
                      onlineransacparms.modelpreserving,...
                      onlineransacparms.samplesliding,...
                      onlineransacparms.datapreserving);
    elseif strcmp(mode,'onemarginal')
        tit = sprintf('%s; %s - %d',fexp,parms.distrib,parms.minlen);
    else
        error('Unknown mode of detection');
    end
    
    allregs{length(allregs) + 1} = regs;
    allts{length(allts) + 1} = ts;

end

namefi = sprintf('matlab_testdetectregs_%s',mode);
if strcmp(mode,'onemarginal')
    namefi = sprintf('%s_%s',namefi,parms.distrib);
else
    for f = 1:length(parms.mtypes)
        namefi = sprintf('%s_%s',parms.mtypes{f});
    end
end

res_filename = sprintf('%s.mat',namefi);
save(res_filename);

gong();
notify('varevalo@uma.es','[test_detectregimes.m] Experiment finished', ...
       ['Experiment started: ' char(datetime_start) newline...
        'Experiment finished: ' char(datetime('now')) newline ...
        'Experiment duration: ' char(datetime('now') - datetime_start) newline ...
        'Results saved in: ' res_filename newline ...
        text_notification newline]);

return;

%% This section shows figures of the results obtained by the first section, but only for one distribution

close all;
clear;
clc;

% --- load your file

load('your .mat file');

ca = ExperimentCatalog(0);
regsperf = RegimesPerformance(allregs,allts,[1:length(ca)]);
RegimesPerformanceShow(regsperf,distname);

return;

%% Shows figures of the results of the first section for comparing all distributions

close all;
clear;
clc;

% --- write down here the files you obtained from the first section for
% each of the distributions

dexp2 = load('your file for EXP2.mat');
dln3 = load('your file for LN3.mat');
dll3 = load('your file for LL3.mat'); 

% --- do not touch from this point on

% pairwise comparisons 

if dexp2.maxdatatouse ~= dln3.maxdatatouse
    warning('Not equal maxdatatouse');
    maxdatatouse = min(dexp2.maxdatatouse,dln3.maxdatatouse);
else
    maxdatatouse = dexp2.maxdatatouse;
end

ca = ExperimentCatalog(0);
numscns = length(ca);

regsperfexp2 = RegimesPerformance(dexp2.allregs,dexp2.allts,[1:numscns]);
percexplexp2 = zeros(1,numscns);
for f = 1:numscns
    percexplexp2(f) = regsperfexp2{f}.numexpl / regsperfexp2{f}.scnlen;
end
boxplotexp2 = [];
boxplottsexp2 = [];
boxplottsexp2names = {};
for f = 1:numscns
    if regsperfexp2{f}.numregs == 0
        boxplotexp2 = [boxplotexp2 ; 0,0,0,0,0];
    else
        [Q1,Q2,Q3,lowerWhisker,upperWhisker] = boxplotofvector(regsperfexp2{f}.reglens);
        boxplotexp2 = [boxplotexp2 ; Q1,Q2,Q3,lowerWhisker,upperWhisker];
    end
    ts = regsperfexp2{f}.comptimes;
    ts = ts(~isnan(ts));
    boxplottsexp2 = [boxplottsexp2; ts(:)];
    for g = 1:length(ts)
        boxplottsexp2names{length(boxplottsexp2names) + 1} = regsperfexp2{f}.scnname;
    end
end

regsperfln3 = RegimesPerformance(dln3.allregs,dln3.allts,[1:numscns]);
percexplln3 = zeros(1,numscns);
for f = 1:numscns
    percexplln3(f) = regsperfln3{f}.numexpl / regsperfln3{f}.scnlen;
end
boxplotln3 = [];
boxplottsln3 = [];
boxplottsln3names = {};
for f = 1:numscns
    if regsperfln3{f}.numregs == 0
        boxplotln3 = [boxplotln3 ; 0,0,0,0,0];
    else
        [Q1,Q2,Q3,lowerWhisker,upperWhisker] = boxplotofvector(regsperfln3{f}.reglens);
        boxplotln3 = [boxplotln3 ; Q1,Q2,Q3,lowerWhisker,upperWhisker];
    end
    ts = regsperfln3{f}.comptimes;
    ts = ts(~isnan(ts));
    boxplottsln3 = [boxplottsln3; ts(:)];
    for g = 1:length(ts)
        boxplottsln3names{length(boxplottsln3names) + 1} = regsperfln3{f}.scnname;
    end
end

regsperfll3 = RegimesPerformance(dll3.allregs,dll3.allts,[1:numscns]);

boxplotdiff = [];
boxplotdiffgrps = {};
for f = 1:numscns
    if (regsperfexp2{f}.numregs > 0) && (regsperfln3{f}.numregs > 0)
        sample1 = regsperfexp2{f}.reglens;
        sample2 = regsperfln3{f}.reglens;
        % generate a sample of the difference sample1-sample2 by
        % bootstrapping
        lsd = 1000;
        samplediff = nan(1,lsd); % sample of the differences of reglens in the same scenario
        for g = 1:lsd
            lr1 = datasample(sample1,1);
            lr2 = datasample(sample2,1);
            samplediff(g) = lr1 - lr2;
        end
        boxplotdiff = [boxplotdiff ; samplediff(:)];
        for g = 1:lsd
            boxplotdiffgrps{length(boxplotdiffgrps)+1} = regsperfexp2{f}.scnname;
        end
    end
end

% threewise comparisons

bxsqd = [];
bxsqdgrps = {};
for f = 1:numscns
    if (regsperfexp2{f}.numregs > 0) && (regsperfln3{f}.numregs > 0) && (regsperfll3{f}.numregs > 0)
        bxsqd = [bxsqd ; regsperfexp2{f}.sqds(:)];
        bxsqdgrps = vertcat(bxsqdgrps,repmat({'EXP'},length(regsperfexp2{f}.sqds),1));
        bxsqd = [bxsqd ; regsperfln3{f}.sqds(:)];
        bxsqdgrps = vertcat(bxsqdgrps,repmat({'LN'},length(regsperfln3{f}.sqds),1));
        bxsqd = [bxsqd ; regsperfll3{f}.sqds(:)];
        bxsqdgrps = vertcat(bxsqdgrps,repmat({'LL'},length(regsperfll3{f}.sqds),1));
    end
end
figure;
h = boxplot(bxsqd,bxsqdgrps);
grid;
ylabel('dist. (density)');
title('squared distances comparisons');
set(findobj(h, 'Type', 'Line'), 'LineWidth', 2);

figure;
hold on;
grid;
plot(percexplexp2,'.r');
plot(percexplln3,'sb');
xlabel('scenario');
ylabel('% expl.');
legend('EXP','LN');
title('% explained deployed');

figure;
h = boxplot([percexplexp2(:),percexplln3(:)]);
set(findobj(h, 'Type', 'Line'), 'LineWidth', 2);
xticklabels({'EXP','LN'});
grid;
title('% explained comparison')

figure;
hold on;
grid;
plot([1,numscns],[0,0],'--k','LineWidth',2);
plot(percexplln3 - percexplexp2,'*');
xlabel('scenario');
ylabel('% expl. EXP2 - LN3');
title('% explained difference');

figure;
boxplot(percexplln3 - percexplexp2);
grid;
xticklabels('LN - EXP');
title('% explained difference');

figure;
hold on;
grid;
wq = 0.1;
hd = 0.4;
for f = 1:numscns
    h = plot(f-hd/2,boxplotexp2(f,2),'or','MarkerSize',8);
    if f == 1
        hexp2 = h;
    end
    plot([f-hd/2-wq,f-hd/2+wq],boxplotexp2(f,1)*[1 1],'-r','LineWidth',2);
    plot([f-hd/2-wq,f-hd/2+wq],boxplotexp2(f,3)*[1 1],'-r','LineWidth',2);
    plot([f-hd/2,f-hd/2],[boxplotexp2(f,1),boxplotexp2(f,3)],':r','LineWidth',2);

    h = plot(f+hd/2,boxplotln3(f,2),'ob','MarkerSize',8);
    if f == 1
        hln3 = h;
    end    
    plot([f+hd/2-wq,f+hd/2+wq],boxplotln3(f,1)*[1 1],'-b','LineWidth',2);
    plot([f+hd/2-wq,f+hd/2+wq],boxplotln3(f,3)*[1 1],'-b','LineWidth',2);
    plot([f+hd/2,f+hd/2],[boxplotln3(f,1),boxplotln3(f,3)],':b','LineWidth',2);
end
xticks(1:numscns);
legend([hexp2;hln3],{'EXP';'LN'});
title('Regime length comparison');

figure;
boxplot(boxplotdiff,boxplotdiffgrps);
ylabel('EXP - LN length');
grid;
xticks(1:numscns);
title('Regime length comparison II');

