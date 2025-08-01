function [regs,ts] = RegimeDetection(S,mode,parms,withtrace)
% Perform detection of regimes in a given scenario.
%
% S -> sequence of roundtrip times.
% MODE -> detection mode: 'onemarginal'
% PARMS -> detection parms:
%           'onemarginal' -> a struct with:
%                               .distrib -> type of the distrib (see 
%                                           ModelCreate()).
%                               .minlen -> minimum length to fit the
%                                          distrib.
%
% REGS <- matrix with the detected regimes: one row per regime with these
%         columns: index of first roundtrip time, index of last roundtrip
%         time, model_as_coeffs (see ModelToCoeffs) for the regime
%         Notice that regimes may overlap, for instance if the parameters
%         include sample sliding. Indexes as w.r.t. the ones of S.
% TS <- vector with the times employed in processing each round-trip of the
%       scenario. Those that have not calculated the fit/gof are stored as
%       NaN, thus TS get the same length as the length of the scenario.

    regs = [];
    ts = [];
    n = length(S);
    if n > 0

        ts = nan(1,n);

        if withtrace
            fprintf(sprintf('Detecting regimes in %d data with mode %s:\r\n',n,mode));
        end

        if strcmp(mode,'onemarginal')

            ind0 = 1;
            lastm = ModelCreate(parms.distrib); % undefined model
            lastminds = [0,0]; % range of the previously defined model
            for f = 1:n
                progress(f,n,'\t','regimedetect_onemarginal',withtrace);
                if f - ind0 + 1 >= parms.minlen % range [ind0:f] to check
                    t0 = tic;
                    [m,~] = ModelAssess(S(ind0:f),ind0,f,{parms.distrib});
                    ts(f) = toc(t0);
                    if isempty(m) % model failed; maybe a previous one ok
                        if lastm.defined % previous model ended here
                            regs = [regs ; lastminds(1), lastminds(2), ModelToCoeffs(lastm)];
                            lastminds(1) = f; % undefine/reset last model
                            lastminds(2) = f;
                            lastm = ModelCreate(parms.distrib); 
                            ind0 = f; % start sliding window here
                        else % no previous model; slide the window forward
                            ind0 = ind0 + 1;
                        end
                    else % model fitted+goffed ok; go on growing it
                        lastminds = [ind0,f];
                        lastm = m; 
                    end
                end
            end
            if lastm.defined % last model not added yet to the list (they are only added when failed)
                regs = [regs ; lastminds(1), lastminds(2), ModelToCoeffs(lastm)];
            end

        else
            error('Unknown mode for regime detection');
        end

    end

end

