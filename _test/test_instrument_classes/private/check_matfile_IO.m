function [ok,mess] = check_matfile_IO (ver_str, save_variables, filepath,varargin)
% Save to or read test data to\from special mat files, with the file names 
% which  describes the file version and the contents of the test
% information, stored in these files. 
%
% Inputs:
% ver_str        -- the name of the version string e.g. ver0 for old
%                   version ver1 for version 1 etc. This name would be used
%                   as prefix to the file name, to identify the file
%                   version for user.
% save_variables -- if true, saves sample variables, if false load
%                   them from the file
% filepath       -- the location of source test files to read on hdd.
%                   If the routine writes to disk, it writes
%                   test files into temporary directory defined by tmp_dir
%                   function.
% varargin       -- variables to save/load to/from file. The main part of
%                   each filename consists of the name of these variables,
%                   identified using Matlab function "inputname".
% NOTE:
% for "inputname" function work correctly, one needs to specify all
% inputs as variables, e.g. calling workspace needs to have
% ver_var = 'ver_str';
% save_var = true;
% filepath= "some_path";
%  my_var = some_var_value for call in the
% form:
%>> check_matfile_IO (ver_var, save_var, filepath,my_var)
% to be correct and define the name of the test file as:
% 'ver_str_my_var.mat'
%  The routine can not be called as 
%>> check_matfile_IO (ver_var, true, filepath,my_var) as this will break the
% "inputname" function operations after ver_var variable.
%
mess = '';
ok = true;
for i=1:numel(varargin)
    class_name = class(varargin{i});
    arg_name = inputname(i+3);
    flname = [ver_str,'_',class_name,'_',arg_name,'.mat'];
    if save_variables
        eval([arg_name,' = varargin{i};']);
        try
            save(fullfile(tmp_dir,flname),arg_name);
        catch
            mess=['*** ERROR: Problem writing ',arg_name,' to ',flname];
            ok = false;
        end
    else
        tmp = load(fullfile(filepath,'saved_class_versions_as_mat_files',flname),arg_name);
        if ~isequal(varargin{i},tmp.(arg_name))
            ok = false;
            mess=sprintf('*** ERROR: Argument %s read from %s does not match original',arg_name,flname);
        end
    end
end
