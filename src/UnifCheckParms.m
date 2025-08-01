function UnifCheckParms(a,b)
% Produce an error if the parameters are invalid for an uniform.

    if ~UnifIsValid(a,b)
        error('Invalid parameters for an uniform');
    end

end