function m = ModelCreateRnd(type,mode)
% Create and define a model of type TYPE in mode MODE.
%
% MODE -> one of the following:
%           'typrnd' -> create the model with params drawn uniformly from
%                       the typical lower and upper bounds given by
%                       ModelTypParmBounds.
%           'min' -> create the model with the minimum values of all parms
%           'max' -> create the model with the maximum values of all parms

    m = ModelCreate(type);
    ps = ModelTypParmBounds(type);
    nparms = size(ps,1);
    m.defined = 1; % just to force to gather a vector of coeffs, with undefined values
    coeffs = ModelToCoeffs(m);

    % Some distributions may provide bounds that depend on one
    % another (e.g., uniform: b must be > a), thus we iterate until
    % creating a valid model.
    finish = 0;
    while ~finish
        if strcmp(mode,'typrnd')
            for f = 1:nparms
                coeffs(f + 1) = myrnd(ps(f,1),ps(f,2));
            end
        elseif strcmp(mode,'min')
            for f = 1:nparms
                coeffs(f + 1) = ps(f,1);
            end        
        elseif strcmp(mode,'max')
            for f = 1:nparms
                coeffs(f + 1) = ps(f,2);
            end        
        else
            error('Unknown model type');
        end
    
        m = ModelFromCoeffs(coeffs);
        if m.defined
            finish = 1;
        end
    end
    
end

function num = myrnd(xmin, xmax)
    num = xmin + (xmax - xmin) * rand();
end 