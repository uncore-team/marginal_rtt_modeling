function LoglogisticCheckParms(a,b,c)
% Produce an error if the parms are invalid.

    if ~LoglogisticIsValid(a,b,c)
        error('Invalid parameters for a loglogistic');
    end

end