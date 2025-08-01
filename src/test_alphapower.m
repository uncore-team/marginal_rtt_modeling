% Test for calculate beta/power; it also calculates alpha

clc;
close all;
clear; 

% --- write down the name of the target distribution for alpha/power (EXP2, LN3, LL3)

mtarget = ModelCreate('EXP2');

% --- write down the vector of sample sizes to test

samplesizes = [20:100:10000]; 

% --- do not change anything from this point on

numtestspersamplesize = 10000;
modelstypes = ModelTypes(2);
for si = 1:length(samplesizes)

    s = samplesizes(si);
    fprintf('===> TESTING samplesize %d... ',s);
    progress(si,length(samplesizes),'','si_in_testpower',1);

    for f = 1:length(modelstypes)

        fprintf('----> Target %s for source %s (sample size %d)... ',mtarget.type,modelstypes{f},s);
        progress(f,length(modelstypes),'','f_in_testpower',1);

        nrejs = 0;
        nunfit = 0;
        nungof = 0;
        nvalid = 0;
        for t = 1:numtestspersamplesize
            
            progress(t,numtestspersamplesize,'\t','t_in_testpower',1);

            % create a model source
            msource = ModelCreateRnd(modelstypes{f},'typrnd');
            
            % generate sample from the source model
            ds = ModelRnd(msource,1,s);
            
            % fit target model to data
            mfit = ModelFit(ds,1,length(ds),mtarget.type);
            if mfit.defined
                % gof the target model
                [reject,~,thresh] = ModelGof(mfit,ds,0); 
                if isnan(thresh)
                    nungof = nungof + 1;
                else
                    nvalid = nvalid + 1;
                    nrejs = nrejs + reject;
                end
            else
                nunfit = nunfit + 1;
            end

        end
        fprintf('\n\tRESULTS:\n');
        fprintf('\t\tun-fits: %d (%.2f%% of total)\n',nunfit,nunfit/numtestspersamplesize*100);
        fprintf('\t\t\tun-gofs: %d (%.2f%% of fitted)\n',nungof,nungof/(numtestspersamplesize - nunfit)*100);
        fprintf('\t\tvalids:  %d (%.2f%% of total)\n',nvalid,nvalid/numtestspersamplesize*100);
        if strcmp(modelstypes{f},mtarget.type)
            fprintf('\t\t*** ALPHA of %s: %f\n',mtarget.type,nrejs/nvalid);
        else
            fprintf('\t\t+++ POWER of %s against %s: %f\n',mtarget.type,modelstypes{f},nrejs/nvalid);
        end
        fprintf('\n');

    end

end
