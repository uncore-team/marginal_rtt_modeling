function progress(f,n,preffix,whoami,withtrace)
% Do a progress step and show the progress if WITHTRACE.
% F must be from 1 to N.
% PREFFIX will be appended at the start of the fprintf line.
% WHOAMI must be a unique text to identify the caller of the the function.
% If F == 1, init the process automatically.
persistent memory

    if isempty(memory)
        memory = containers.Map('KeyType', 'char', 'ValueType', 'any');
    end
    if ~memory.isKey(whoami)
	    memory(whoami) = {}; % initialize for new caller
    end
    
    if f == 1
        memory(whoami) = {tic,... % time handler
                          0,...   % old perc
                          0};     % old toc
    end
    
   	myd = memory(whoami);
    perc = f / n * 100;
    if (floor(perc/5) > floor(myd{2}/5)) % per 5% 
    	myd{2} = perc;
        if withtrace
            t = toc(myd{1});
            inct = t - myd{3};
            fprintf('%s%.2f%%, #%d; steptime %f s; total %f s (%f m, %f h)\n',sprintf(preffix),perc,f,inct,t,t/60,t/3600);
            drawnow;
            myd{3} = t;
        end
    end                
    memory(whoami) = myd;

end
