function [fdir,fexp,data] = ExperimentGet(ca,c,n,minind,maxind,transfintospeed,robotspeed,trace)
% Given an experiment identification, return the path and filename for it.
%
% CA -> catalog, obtained from ExperimentCatalog()
% C -> class; a string: 'realoct2023','realpapersensors','sim'
% N -> index, from 1, in the class.
% MININD, MAXIND -> range of data to extract from the scenario; all the
%                   scenario if MININD <= 1, MAXIND >= length(scenario).
% TRANSFINTOSPEED -> 1 to transform the data from time (millisecs) into
%                    meters travelled by a hypothetical robot; 0 to not
%                    transform.
% ROBOTSPEED -> hypothetical robot speed in m/s if TRANSFINTOSPEED == 1;
%               ignored otherwise.
% TRACE -> 1 to see some trace.
%
% FDIR <- folder path, not ended in '/'
% FEXP <- filename with extension
% DATA <- rtts read from the experiment, as a column vector

    if n <= 0
        error('Invalid N');
    end
    if maxind < minind
        error('Invalid range');
    end

    f = ExperimentCatalogFind(ca,c,n);
    fdir = ca{f}.fdir;
    fexp = ca{f}.fexp;
    fext = ca{f}.fext;

    if strcmp(c,'sim') % these are generated, not loaded

        if trace
            fprintf('Generating simulated experiment [%d]...\r\n',n);
        end
        rng(54); % for the scenario to not vary between experiments
        switch n
            case 1
                data = LoglogisticRnd(1000,2,0.3,2000,1);                
            case 2
                data = [ LoglogisticRnd(1000,2,0.25,2000,1) ; ...
                         LoglogisticRnd(1010,10,0.1,500,1) ; ...
                         LoglogisticRnd(950,20,0.4,500,1) ];
            case 3
                data = LognormalRnd(1000,5,0.1,1,2000);
            case 4
                data = ExponentialRnd(1000,5,1,2000);
            otherwise
                error('N out of range');
        end

    else % these are loaded from original experiment files or from the official dataset
        fn = sprintf('%s/%s',fdir,fexp);
        if strcmp(fext,'csv') % these come from the official dataset

            data = readmatrix(fn);

        else % the rest come from the original files

            if strcmp(fext,'m') 
    
                run(fn);
                if strcmp(c,'realoct2023')
                    data = historial(:,2); 
                else
                    error('Do not know how to read class %s',c);
                end
    
            elseif strcmp(fext,'txt')
    
                data = load(fn);
    
            elseif strcmp(fext,'mat')
    
                load(fn);
                data = ds;
                clear('ds');

            else
                error('Do not know how to read extension %s',fext);
            end
            
        end

    end

    data = data(:);
    l = length(data);
    if (minind > 1) || (maxind < l)
        data = data(max(1,minind):min(l,maxind));
    end
    if transfintospeed
        data = data / 1000 * robotspeed; % from milliseconds to meters travelled in each step
    end

end
