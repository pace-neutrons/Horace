function test_0_fun
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

mftest_dir = fileparts(mfilename('fullpath'));
load(fullfile(mftest_dir,'/data/testdata_multifit_1.mat'));


% =========================================================================
% Test set_fun
% =========================================================================

% Test_1
% ------
% Set fun on nothing
kk = mfclass;
kk = kk.set_fun;

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Set fun on nothing
kk = mfclass;
kk = kk.set_fun([]);

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Set fun on nothing
kk = mfclass;
kk = kk.set_fun({});

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Dummy set function
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun;

kk_ref = mfclass([w1,w2,w3]);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Try to set free list without parameters
kk = mfclass([w1,w2,w3]);
try
    kk = kk.set_fun(@gauss,'free',[1,0,1]);
    failed = true;
catch
    failed = false;
end
if failed, error('*** Should have failed'), end


% Set global foreground function then local background functions
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss);
kk = kk.set_bfun(@lorentzian);

% Set global foreground function then local background functions
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss);
kk = kk.set_bfun({@lorentzian,@gauss,@expm});

% Set global foreground function then local background functions, all 
% with parameters
% Check that the free and bfree now filled
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4]);
kk = kk.set_bfun(@lorentzian,[50,20,5]);

% Set global foreground function then local background functions, all 
% with parameters - different for the different background functions
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4]);
kk = kk.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]});

% In addition, set free
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk = kk.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'free',[1,1,0]);

% In addition, set some binding
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk = kk.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'bind',{2,1},'free',[1,1,0]);



% =========================================================================
% Test clear_fun
% =========================================================================

% Test_2
% ------
% Clear empty object
kk = mfclass;
kk = kk.clear_fun;

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Clear empty object
kk = mfclass;
kk = kk.clear_fun([]);

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Clear some functions
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk = kk.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'bind',{2,1},'free',[1,1,0]);
kk = kk.clear_bfun;

kk_ref = mfclass([w1,w2,w3]);
kk_ref = kk_ref.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Clear some functions
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk = kk.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'bind',{2,1},'free',[1,1,0]);
kk = kk.clear_fun;

kk_ref = mfclass([w1,w2,w3]);
kk_ref = kk_ref.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'bind',{2,1},'free',[1,1,0]);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Clear some functions
kk = mfclass([w1,w2,w3]);
kk = kk.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk = kk.set_bfun(@lorentzian,{[50,20,5],[51,20,5],[52,20,5]},'bind',{2,1},'free',[1,1,0]);
kk = kk.clear_bfun(2);

kk_ref = mfclass([w1,w2,w3]);
kk_ref = kk_ref.set_fun(@gauss,[100,10,4],'free',[1,0,1]);
kk_ref = kk_ref.set_bfun(1,@lorentzian,[50,20,5],[1,1,0],'bind',{2,1});
kk_ref = kk_ref.set_bfun(3,@lorentzian,[52,20,5],[1,1,0],'bind',{2,1});
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end

