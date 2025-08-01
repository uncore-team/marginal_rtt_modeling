function ds = UnifRnd(a,b,n,m)
% Draw a NxM sample of the given uniform.

    UnifCheckParms(a,b);

    ds = unifrnd(a,b,n,m);

end