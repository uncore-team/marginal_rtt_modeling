function names = ModelTypes(withoutsome)
% Return a cell with as many model types as they exist, in the order they
% should be used for modelling.
%
% WITHOUTSOME <- 0 for including all models; 1 for including all except
%                BERN,NORM,UNIF; 2 for including all except BERN
%
% NAMES <- a cell with a text for each model

    mainnames = { 'LL3', 'LN3', 'EXP2' };
    bernname = 'BERN';
    othernames = { 'NORM', 'UNIF' };

    names = mainnames;
    switch withoutsome
        case 0
            names{end + 1} = bernname;
            for f = 1:length(othernames)
                names{end + 1} = othernames{f};
            end
        case 1
            % already done
        case 2
            for f = 1:length(othernames)
                names{end + 1} = othernames{f};
            end
    end

end