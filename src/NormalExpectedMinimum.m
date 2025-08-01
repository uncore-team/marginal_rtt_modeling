function emin = NormalExpectedMinimum(ss)
% Return the expectation of the minimum value of a standard normal N(0,1)
% for the given sample size.
% This has been calculated through Monte Carlo 

    coeffs1 = [7.23627503388151e-15	-1.02683487723141e-11	5.83263735541382e-09	-1.70207194941458e-06	0.000274903468154010	-0.0259074972239840	-1.45593278304964];
    coeffs2 = [8.26284732693894e-38	-4.59320406864933e-33	1.11114452016236e-28	-1.53572494293457e-24	1.33905053093269e-20	-7.68082314362085e-17	2.93708297952191e-13	-7.45484883924418e-10	1.24134707257001e-06	-0.00139709172619402	-2.57017378726021];
    endspartsss = [400 10000];
    funpart1 = @(ss) polyval(coeffs1,ss);
    funpart2 = @(ss) polyval(coeffs2,ss);
    funparts = {funpart1,funpart2};
    kperc = 0.999999;

    [emin,~] = weld_functions(funparts,endspartsss,kperc,ss);

end