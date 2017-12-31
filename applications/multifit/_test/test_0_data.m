function test_0_data
% Tests of syntax

% Test setting data
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
% Test append_data
% =========================================================================

% Test_1
% ------
% Append x-y-e data to existing x-y-e data
kk = mfclass(x1,y1,e1);
kk = kk.append_data(x2,y2,e2);

kk_ref = mfclass(c1,c2);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Test_2
% ------
% Append a bunch of datasets
kk = mfclass(x1,y1,e1);
kk = kk.append_data([w1,w2,w3],c2);
kk = kk.append_data([s1,s3],{c1,c3});

kk_ref = mfclass(c1,[w1,w2,w3],c2,[s1,s3],{c1,c3});
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end

% Test_3
% ------
% Append nothing
kk = mfclass(x1,y1,e1);
kk = kk.append_data();

kk_ref = mfclass(x1,y1,e1);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% =========================================================================
% Test replace_data
% =========================================================================

% Test_1
% ------
% Replace some data
kk = mfclass([w1,w2],{c1,c2,c3});
kk = kk.replace_data([2,4],w3,c3);

kk_ref = mfclass([w1,w3],{c1,c3,c3});
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Test_2
% ------
% Try to replace with a datset of different type
kk = mfclass([w1,w2],{c1,c2,c3});
try
    kk = kk.replace_data([1,2],w1,c3);
    failed = true;
catch
    failed = false;
end
if failed, error('*** Should have failed'), end


% Test_3
% ------
% Try to replace with a datset of different type
kk = mfclass(w1,w2);
try
    kk = kk.replace_data(w3,c3);
    failed = true;
catch
    failed = false;
end
if failed, error('*** Should have failed'), end


% Test_4
% ------
% Try to replace with a different number of datasets
kk = mfclass(w1,w2);
try
    kk = kk.replace_data(w3);
    failed = true;
catch
    failed = false;
end
if failed, error('*** Should have failed'), end


% Test_5
% ------
% Replace going via clearing data
kk = mfclass(w1,w2);
kk = kk.replace_data([w2,w3]);

kk_ref = mfclass(w2,w3);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Test_6
% ------
% Replace a single dataset with one of same type
kk = mfclass(w1,c1);
kk = kk.replace_data(2,c2);

kk_ref = mfclass(w1,c2);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Test_7
% ------
% Replace a single dataset with one of different type - this actually 
% is designed to fail (too complex to handle!)
kk = mfclass(w1,c1);
try
    kk = kk.replace_data(2,w2);
    failed = true;
catch
    failed = false;
end
if failed, error('*** Should have failed'), end


% Test_8
% ------
% Replace nothing
kk = mfclass(w1,c1);
kk = kk.replace_data();

kk_ref = mfclass(w1,c1);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Test_9
% ------
% Replace nothing
kk = mfclass(w1,c1);
kk = kk.replace_data([]);

kk_ref = mfclass(w1,c1);
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% =========================================================================
% Test remove_data
% =========================================================================

% Test_1
% ------
% Remove all data
kk = mfclass(w1,c1);
kk = kk.remove_data([1,2]);

kk_ref = mfclass;
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end


% Test_2
% ------
% Remove some data
kk = mfclass(c1,[w1,w2,w3],c2,[s1,s3],{c1,c3});
kk = kk.remove_data([7,3,9]);

kk_ref = mfclass(c1,[w1,w3],c2,s1,{c1});
if ~equal_to_tol(kk_ref,kk)
    error('***ERROR!')
end





