% Assumes have created a data file
load('testdata_multifit_1.mat')

% An exanple fit with old multifit
w3 = [w1,w2,w3];
[wfit,fitdata] = multifit (w3, @mftest_gauss, [100,45,10], @mftest_bkgd, [0,0], 'list', 2);

