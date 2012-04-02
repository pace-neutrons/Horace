% Tests on single x-y-e triple
% ----------------------------
%rootpath=fileparts(mfilename('fullpath'));
rootpath='c:\temp';
load(fullfile(rootpath,'test_mftest_datasets.mat'));

pin=[100,50,7,0,0];

% Reference output
% ----------------
% Create reference output
[y1_fref, wstruct1_fref, w1_fref, p1_fref] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1, @mftest_gauss_bkgd, pin);

% Slow oonvergence, print output
[y1_fslow, wstruct1_fslow, w1_fslow, p1_fslow] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1, @mftest_gauss_bkgd, pin, [1,0,1,0,0], 'list',2);   

% Equivalence of split foreground and background functions with single function
[y1_fsigfix, wstruct1_fsigfix, w1_fsigfix, p1_fsigfix] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd, pin, [1,0,1,1,1]);   
[y1_fsigfix_bk, wstruct1_fsigfix_bk, w1_fsigfix_bk, p1_fsigfix_bk] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, pin(1:3), [1,0,1], @mftest_bkgd, pin(4:5));

tol=0;
if ~equal_to_tol(y1_fsigfix,y1_fsigfix_bk,tol)
    error('Test failed: split foreground and background functions not equivalent to single function')
end

% Test binding
% ------------------

% Fix ratio of two of the foreground parameters
prat=[6,0,0,0,0]; pbnd=[3,0,0,0,0];
[y1_fbind1_ref, wstruct1_fbind1_ref, w1_fbind1_ref, p1_fbind1_ref] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd_bind, [pin,prat,pbnd], [0,0,1,1,0,zeros(1,10)]);

[y1_fbind1_1, wstruct1_fbind1_1, w1_fbind1_1, p1_fbind1_1] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, pin(1:3), [1,0,1], {1,3,0,6}, @mftest_bkgd, pin(4:5), [1,0]);

tol=0;
if ~equal_to_tol(y1_fbind1_ref,y1_fbind1_1,tol)     % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
    error('Test failed: binding problem')
end

[y1_fbind1_2, wstruct1_fbind1_2, w1_fbind1_2, p1_fbind1_2] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...    % Same, but pick ratio from input ht and sig
    @mftest_gauss, [6*pin(3),pin(2:3)], [1,0,1], {1,3}, @mftest_bkgd, pin(4:5), [1,0]);

tol=0;
if ~equal_to_tol(y1_fbind1_ref,y1_fbind1_2,tol)
    error('Test failed: binding problem')
end

% Fix ratio of two of the foreground, and two of the background parameters
prat=[6,0,0,0.01,0]; pbnd=[3,0,0,5,0];
[y1_fbind2_ref, wstruct1_fbind2_ref, w1_fbind2_ref, p1_fbind2_ref] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd_bind, [pin,prat,pbnd], [0,0,1,0,1,zeros(1,10)]);

[y1_fbind2, wstruct1_fbind2, w1_fbind2, p1_fbind2] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, pin(1:3), [1,0,1], {1,3,0,6}, @mftest_bkgd, pin(4:5),'', {{1,2,1,0.01}});

tol=0;
if ~equal_to_tol(y1_fbind2_ref,y1_fbind2,tol)     % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
    error('Test failed: binding problem')
end

% Fix parameters across the foreground and background
prat=[0,0,0.2,0,1/300]; pbnd=[0,0,4,0,2];
[y1_fbind3_ref, wstruct1_fbind3_ref, w1_fbind3_ref, p1_fbind3_ref] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd_bind, [100,50,5,20,0,prat,pbnd], [0,1,0,1,0,zeros(1,10)]);

[y1_fbind3, wstruct1_fbind3, w1_fbind3, p1_fbind3] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, [100,50,5], [0,1,1], {3,1,1,0.2}, @mftest_bkgd, [20,0],'', {{2,2,0,1/300}});

tol=0;
if ~equal_to_tol(y1_fbind3_ref,y1_fbind3,tol)  % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
    error('Test failed: binding problem')
end

% Yet more binding of parameters
prat=[2,0,0.2,0,1/300]; pbnd=[2,0,4,0,2];
[y1_fbind4_ref, wstruct1_fbind4_ref, w1_fbind4_ref, p1_fbind4_ref] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss_bkgd_bind, [100,50,5,20,0,prat,pbnd], [0,1,0,1,0,zeros(1,10)]);

[y1_fbind4, wstruct1_fbind4, w1_fbind4, p1_fbind4] = multifit_test_gauss1d (x1,y1,e1,wstruct1,w1,...
    @mftest_gauss, [100,50,5], '', {{1,2},{3,1,1,0.2}}, @mftest_bkgd, [20,0],'', {{2,2,0,1/300}});

tol=0;
if ~equal_to_tol(y1_fbind4_ref,y1_fbind4,tol)  % can only compare output y values - we've fudged the reference fit function, and parameters are not 'real'
    error('Test failed: binding problem')
end


%%  Causes of error
% ------------------
% The following is an error because of that ambiguity problem - except is there really ambiguity with binding?

% [yfit, f] = multifit (x1, y1, e1, @gauss, [42,pin(2:3)], [1,0,1], {1,3}, @bkgd, pin(4:5),'', {1,2,1,0.01}, 'list',2);
