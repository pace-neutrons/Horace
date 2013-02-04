function test_file_input
% Tests functionality of methods that can take object or file input

% =================================================================================================
% Read in test data sets
% =================================================================================================
% Note: this function assumes that read(sqw,sqwfilename) works correctly
tmp_path=fullfile(fileparts(which(mfilename)),'testdata');
currdir=pwd;
try
    cd(tmp_path)
    [sqw1d_arr,sqw2d_arr,d1d_arr,d2d_arr,sqw1d_name,sqw2d_name,d1d_name,d2d_name]=make_testdata;
    cd(currdir)
catch
    cd(currdir)
    error('Unable to read test data')
end

% =================================================================================================
% Perform tests
% =================================================================================================

% =================================================================================================
% Cuts
% =================================================================================================

% Cut of sqw objects or files
% ---------------------------
proj2.u=[-1,1,0];
proj2.v=[1,1,0];

s1_s=cut(sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
s1_s_h=cut_horace(sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
s1_s_s=cut_sqw(sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
s1_f_h=cut_horace(sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
s1_f_s=cut_sqw(sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
try
    s1_s_d=cut_dnd(sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
    failed=false;
catch
    failed=true;
end
if ~failed, error('Should have failed!'), end

try
    s1_f_d=cut_dnd(sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180]);
    failed=false;
catch
    failed=true;
end
if ~failed, error('Should have failed!'), end

if ~equal_to_tol(s1_s,s1_s_h), error('Error in functionality'), end
if ~equal_to_tol(s1_s,s1_s_s), error('Error in functionality'), end
if ~equal_to_tol(s1_s,s1_f_h,'ignore_str',1), error('Error in functionality'), end
if ~equal_to_tol(s1_s,s1_f_s,'ignore_str',1), error('Error in functionality'), end

tmp0_file=fullfile(tempdir,'tmp0.sqw');
tmp_file=fullfile(tempdir,'tmp.sqw');
cut(sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp0_file);
tmp0=read(sqw,tmp0_file);

cut_horace(sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
tmp=read(sqw,tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), error('Error in functionality'), end

cut_sqw(sqw2d_arr(2),proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
tmp=read(sqw,tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), error('Error in functionality'), end

cut_horace(sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
tmp=read(sqw,tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), error('Error in functionality'), end

cut_sqw(sqw2d_name{2},proj2,[0.5,0.02,1],[0.9,1.1],[-0.1,0.1],[170,180],tmp_file);
tmp=read(sqw,tmp_file); if ~equal_to_tol(tmp0,tmp,'ignore_str',1), error('Error in functionality'), end


% Cut of dnd objects or files
% ---------------------------
d1_d=cut(d2d_arr(2),[0.5,0,1.2],[170,180]);
d1_d_h=cut_horace(d2d_arr(2),[0.5,0,1.2],[170,180]);
d1_d_d=cut_dnd(d2d_arr(2),[0.5,0,1.2],[170,180]);
d1_f_h=cut_horace(d2d_name{2},[0.5,0,1.2],[170,180]);
d1_f_d=cut_dnd(d2d_name{2},[0.5,0,1.2],[170,180]);
try
    d1_d_s=cut_sqw(d2d_arr(2),[0.5,0,1.2],[170,180]);
    failed=false;
catch
    failed=true;
end
if ~failed, error('Should have failed!'), end

try
    d1_f_s=cut_sqw(d2d_name{2},[0.5,0,1.2],[170,180]);
    failed=false;
catch
    failed=true;
end
if ~failed, error('Should have failed!'), end

if ~equal_to_tol(d1_d,d1_d_h), error('Error in functionality'), end
if ~equal_to_tol(d1_d,d1_d_d), error('Error in functionality'), end
if ~equal_to_tol(d1_d,d1_f_h,'ignore_str',1), error('Error in functionality'), end
if ~equal_to_tol(d1_d,d1_f_d,'ignore_str',1), error('Error in functionality'), end


% Test arrays of objects
% ----------------------

% =================================================================================================
% Reading data
% =================================================================================================

tmp=read(sqw,sqw2d_name{2});
if ~equal_to_tol(sqw2d_arr(2),tmp,'ignore_str',1), error('Error in functionality'), end

tmp=read_sqw(sqw2d_name{2});
if ~equal_to_tol(sqw2d_arr(2),tmp,'ignore_str',1), error('Error in functionality'), end

tmp=read_horace(sqw2d_name{2});
if ~equal_to_tol(sqw2d_arr(2),tmp,'ignore_str',1), error('Error in functionality'), end

tmp=read(d2d,sqw2d_name{2});
if ~equal_to_tol(d2d_arr(2),tmp,'ignore_str',1), error('Error in functionality'), end

tmp=read_dnd(sqw2d_name{2});
if ~equal_to_tol(d2d_arr(2),tmp,'ignore_str',1), error('Error in functionality'), end

tmp=read(d2d,d2d_name{2});
if ~equal_to_tol(d2d_arr(2),tmp,'ignore_str',1), error('Error in functionality'), end

try
    tmp=read_sqw(d2d_name{2});
    failed=false;
catch
    failed=true;
end
if ~failed, error('Should have failed!'), end

tmp=read_horace(d2d_name{2});
if ~equal_to_tol(d2d_arr(2),tmp,'ignore_str',1), error('Error in functionality'), end

% Read array of files
tmp=read_horace(sqw2d_name);
if ~equal_to_tol(sqw2d_arr,tmp,'ignore_str',1), error('Error in functionality'), end

tmp=read_dnd(sqw2d_name);
if ~equal_to_tol(d2d_arr,tmp,'ignore_str',1), error('Error in functionality'), end

tmp=read_sqw(sqw2d_name);
if ~equal_to_tol(sqw2d_arr,tmp,'ignore_str',1), error('Error in functionality'), end

