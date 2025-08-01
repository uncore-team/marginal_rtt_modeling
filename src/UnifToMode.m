function m = UnifToMode(a,b)
% Return the mode of the uniform; since the uniform has as mode any of the
% values of its interval, this return the mean.

    UnifCheckParms(a,b);

    m = (a + b)/2;

end