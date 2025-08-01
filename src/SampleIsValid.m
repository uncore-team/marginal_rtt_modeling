function va = SampleIsValid(ds)
% Return 1 if the sample is valid for our context.

    va = 0;
    if length(ds) < 2
        return;
    end
    if min(ds) <= 0
        return;
    end
    va = 1;

end