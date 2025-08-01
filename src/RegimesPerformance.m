function regperf = RegimesPerformance(regs,tss,scninds)
% Calculate performance metrics on the given regimes.
%
% SCNINDS -> indexes in the catalog of scenarios of the scenarios.
% TSS -> computation times measured by RegimeDetection(); a cell with one 
%        vector per scenario.
% REGS -> a cell where each element is like the result of
%         RegimeDetection(); each element in the cell corresponds to a
%         given scenario.
%
% REGPERF <- a cell with one element per scenario (same length as REGS);
%            each element is a struct:
%               .scnlen <- the length of the scenario subjected to 
%                          detection.
%               .scnname <- a copy of SCNNAME.
%               .comptimes <- a column vector with the computation times of 
%                             the scenario. Length does not have to 
%                             coincide with the number of processed rtts.
%               .excesstimes <- for each comptimes that has been measured,
%                               time remaining after computing that time
%                               within the next delay. NaN if no comput.
%                               time measured there. Negative if not enough
%                               time for the computation.
%               .batchneeded <- for each comptimes that has been measured,
%                               number of rtts that should wait til
%                               providing a gof result; it is a measure of
%                               the needed batch of rtts needed to work.
%                               NaN if no comp. time measured here or if
%                               not enough rtts exist in the future of this
%                               point to calculate that.
%               .numregs <- number of regimes detected in that scenario
%                           (maybe 0).
%               .reglens <- a vector with the lengths of the regimes
%                           detected in that scenario. Length == .numregs.
%               .numexpl <- total number of rtts contained into some reg.
%               .sqds <- a vector of squared distances calculated with 
%                        sqdist_distrib() for each regime in REGS. This
%                        only works ok if the regimes in REGS contain
%                        indexes that start at the start of the complete
%                        scenarios; if they have been detected in segments
%                        of the scenarios that do not start at 1, this is
%                        wrong.

    nsc = length(regs);
    if length(scninds) ~= nsc
        error('Mismatch between scenario indexes and regimes');
    end

    ca = ExperimentCatalog(0);    

    scnnames = cell(nsc,1);
    for f = 1:nsc
        scnnames{f} = sprintf('%d',scninds(f));
    end
        
    regperf = cell(1,nsc);
    for f = 1:nsc

        [~,~,historial] = ExperimentGet(ca,ca{scninds(f)}.class,ca{scninds(f)}.index,1,Inf,0,0,0);

        scnregs = regs{f};
        nregs = size(scnregs,1);
        ts = tss{f};
        ts = ts(:);
        scnlen = length(ts);
        pfs = struct('scnlen',scnlen,...
                     'scnname',scnnames{f},...
                     'comptimes',ts,...
                     'excesstimes',nan(1,scnlen),...
                     'batchneeded',nan(1,scnlen),...
                     'numregs',nregs,...
                     'reglens',nan(1,nregs),...
                     'numexpl',0,...
                     'sqds',nan(1,nregs));
        for r = 1:nregs % for each regime stored for that scenario
            reg = scnregs(r,:);
            lr = reg(2) - reg(1) + 1;
            pfs.reglens(r) = lr;
            pfs.numexpl = pfs.numexpl + lr;

            m = ModelFromCoeffs(reg(3:end));
            funpdf = @(x) ModelPdf(m,[],x);
            pfs.sqds(r) = sqdist_distrib(funpdf,historial(reg(1):reg(2))); 
        end        
        for g = 1:scnlen-1
            if ~isnan(ts(g))
                nextdelay = historial(g + 1);
                pfs.excesstimes(g) = nextdelay / 1000 - ts(g); % all scenarios store RTTs in milliseconds
                pfs.batchneeded(g) = 1;
                if pfs.excesstimes(g) < 0
                    aux = nextdelay / 1000;
                    auxcount = 0;
                    for h = g + 2 : scnlen 
                        aux = aux + historial(h) / 1000;
                        auxcount = auxcount + 1;
                        if aux >= ts(g)
                            break;
                        end
                    end
                    if aux >= ts(g)
                        pfs.batchneeded(g) = pfs.batchneeded(g) + auxcount;
                    else
                        pfs.batchneeded(g) = NaN;
                    end
                end
            end
        end

        regperf{f} = pfs;

    end

end