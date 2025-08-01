function r = ModelHasOffset(ty)
% Given the type of model, return:
%   
%   0 if that model type has no offset parameter.
%   1 if it has an offset parameter and any sample drawn from the model can
%     contain values equal to the offset (when considering them with
%     infinite precision).
%   2 if it has an offset parameter and the samples drawn from the model
%     cannot contain values equal to the offset (idem).

    if strcmp(ty,'BERN') || strcmp(ty,'NORM') || strcmp(ty,'UNIF')

        r = 0;

    elseif strcmp(ty,'EXP2')

        r = 1;

    elseif strcmp(ty,'LN3') || strcmp(ty,'LL3')

        r = 2;

    else
        error('Invalid model type');
    end  

end