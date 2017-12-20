function test_0_pin
% Tests of syntax

% Test function evaluation
% -------------------------
% At this point we have three different data sets each represented in different ways
%   x1,y1,e1
%   c1 = {x1,y1,e1}
%   s1 = struct with fields x1, y1, e1
%   w1 = IX_dataset_1d
%
% and similarly for datasets 2 and 3

mftest_dir = 'T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\multifit\_test';
load(fullfile(mftest_dir,'/data/testdata_multifit_1.mat'));


% =========================================================================
% Test set_pin
% =========================================================================

% Test_1
% ------
% Set pin on nothing
kk = mfclass;
kk = kk.set_pin;

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Set pin on nothing
kk = mfclass;
kk = kk.set_pin([]);

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Set pin on nothing
kk = mfclass;
kk = kk.set_pin({});

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Currently the following does not work - it is set so as not to.
%
% % Set pin not in a cell array
% kk0 = mfclass([w1,w2,w3]);
% kk0 = kk0.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
% kk0 = kk0.set_bfun(@lorentzian);
% 
% kk1 = kk0.set_bpin({[50,20,5],[51,20,5],[52,20,5]});
% kk2 = kk0.set_bpin([50,20,5],[51,20,5],[52,20,5]);
% if ~equal_to_tol(kk1,kk2)
%     error('***ERROR!')
% end


% A bunch of tests setting parts of the parameter list at a time
kk0 = mfclass([w1,w2,w3]);
kk0 = kk0.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk0 = kk0.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'free',[1,1,0]);

kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss);
kk = kk.set_bfun(@lorentzian);
kk = kk.set_pin([100,10,4]);
kk = kk.set_bpin(1,[50,20,5]);
kk = kk.set_bpin(2,[51,20,5]);
kk = kk.set_bpin(3,[52,20,5]);
kk = kk.set_free([1,0,1]);
kk = kk.set_bfree([1,1,0]);

kk_ref=kk0;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end

