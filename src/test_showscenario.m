% Show an scenario

clear;
close all;

expcat = ExperimentCatalog(0);

% --- scenario to show

scn = 17;

% --- several general parms

distribtouse = 'LL3';
maxdatatouse = 10000;
transformintorobotdistance = 0; % 1-> to transform rtts into the distance travelled by a robot that exhibits those rtts and moves with certain speed 
robotspeed = 0.25; % in m/s, not used if transformintorobotdistance is 0

% --- load the scenario data

[fdir,fexp,historial] = ExperimentGet(expcat,expcat{scn}.class,expcat{scn}.index,...
                                      -Inf,Inf,...
                                      transformintorobotdistance,robotspeed, ...
                                      1);
datatouse = min(maxdatatouse,length(historial));
historial = historial(1:datatouse);
fprintf('SCENARIO #%d: data with %d roundtrip times.\n',scn,length(historial));

% --- load previously computed regimes or calculate new ones or use no regimes at all

% -- to load an already computed set of regimes for a distribution,
% uncomment one of the following:

%load('matlab_testdetectregs_onemarginal_EXP2_solo10000rtts.mat'); distname = 'EXP';
%load('matlab_testdetectregs_onemarginal_LN3_noshiftcorrection_nostdbug_cohenmomentsforcef-1.mat'); distname = 'LN';
%load('matlab_testdetectregs_onemarginal_LL3_expooffset_noshiftcorrection_solo1000rtts.mat'); distname = 'LL3';
%regs = allregs{scn};

% -- to not detect any regime, uncomment this:

%regs = {};

% -- to perform the regime detection now, uncomment this:

fprintf('Detecting regimes with %s...\n',distribtouse);
[regs,~] = RegimeDetection(historial,'onemarginal',...
                          struct('distrib',distribtouse,...
                                 'minlen',20),...
                          1);


% --- do not change anything from this point on

if transformintorobotdistance
    units = 'meters';
else
    units = 'millisecs';
end
tit = sprintf('%s',fexp);
fprintf('Experiment figures...\r\n');
ScenarioShow(historial,tit,regs,[],units);
figure;
hold on;
plot(cumsum(historial)/1000,movmean(historial/1000,20),'m-','LineWidth',2);
grid;
xlabel('Time (s)');
ylabel('RTT (s)');


fprintf('Done.\r\n');