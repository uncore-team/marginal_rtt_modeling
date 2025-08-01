function ds = NormRnd(mu,sigma,n,m)
% Draw a NxM sample of the given normal. 
%
% Mathematically, it is a truncated normal at 0: https://en.wikipedia.org/wiki/Truncated_normal_distribution#cite_note-ist-lecture-4-1
% Greene, William H. (2003). Econometric Analysis (5th ed.). Prentice Hall. ISBN 978-0-13-066189-0.

    NormCheckParms(mu,sigma);
    
    ds = normrnd(mu,sigma,n,m);
    finish = 0;
    while ~finish
        [indsr,indsc] = find(ds <= 0);
        if isempty(indsr)
            finish = 1;
        else
            ds(indsr,indsc) = normrnd(mu,sigma,length(indsr),length(indsc));
        end
    end

end
