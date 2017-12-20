function test_0_free
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
% Test set_free
% =========================================================================

% Test_1
% ------
% Set free on nothing
kk = mfclass;
kk = kk.set_free;

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Set pin on nothing
kk = mfclass;
kk = kk.set_free([]);

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Set fun on nothing
kk = mfclass;
kk = kk.set_free({});

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% A bunch of tests setting parts of the free list at a time
% ---------------------------------------------------------
kk0 = mfclass([w1,w2,w3]);
kk0 = kk0.set_fun(@gauss,[100,10,4]);
kk0 = kk0.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]});

% Do nothing:
kk = kk0.set_free([]);
kk_ref = kk0;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% One function:
kk = kk0.set_bfree(2,[1,1,0]);

% All functions:
kk = kk0.set_bfree('all',[1,1,0]);

% All functions:
kk = kk0.set_bfree([1,0,0]);




% =========================================================================
% Test clear_free
% =========================================================================

% Test_2
% ------
% Clear empty object
kk = mfclass;
kk = kk.clear_free;

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Clear empty object
kk = mfclass;
kk = kk.clear_free([]);

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Clear empty object
kk = mfclass;
kk = kk.clear_free('all');

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Clear some functions
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk = kk.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'bind',{2,1},'free',[1,1,0]);
kk = kk.clear_bfree;

kk_ref = mfclass([w1,w2,w3]);
kk_ref = kk_ref.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk_ref = kk_ref.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'bind',{2,1});
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Clear some functions
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk = kk.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'bind',{2,1},'free',[1,1,0]);
kk = kk.clear_bfree(2);
kk = kk.clear_free(1);

kk_ref = mfclass([w1,w2,w3]);
kk_ref = kk_ref.set_fun(@gauss,[100,10,4]);
kk_ref = kk_ref.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},...
    'free',{[1,1,0],[1,1,1],[1,1,0]},'bind',{2,1});
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end
