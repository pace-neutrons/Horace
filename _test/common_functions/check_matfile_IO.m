function check_matfile_IO (ver_str, save_variables, filepath,varargin)
% Save or read test data to\from special mat files, with the file names
% which describe the file version and the contents of the test
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
% Outputs:
% If save_variables input is true:
%                  Saves reference files with the names, constructed from
%                  the inputs in the tmp folder
% If save_variables input is false:
%                   Tries to read reference files from the folder,
%                   specified as filepath.
%                   Throws on assertEqual with error explaining the reason
%                   for failure if the comparison of input variable with
%                   saved data is failed.
%                   Returns silently if comparison is true.
%
% NOTE:
% One needs to exercise caution when working with this function as the
% function uses "inputname" function to identify the variable names and
% then uses these names to construct names of the target files.
%
% for "inputname" function to work correctly, one needs to specify all
% inputs as variables, defined in the calling workspace.
%
% e.g. calling workspace needs to have the following variables:
% ver_str = "ver_str_value" -- ver_str variable with char value identifying
%                              the version;
% save_variables  = true;  -- save_variable boolean variable, with value
%                             true or false
% filepath= "some_path";   -- variable identifying the location of the
%                             reference files to read. Routine always
%                             writes reference files into tmp directory
%  my_var = some_var_value    the variables to save/check agains saved version
%
%  All assignments need to be present before
%  call to the check_matfile_IO. The call then comes it in the
% form:
%>> check_matfile_IO (ver_var, save_var, filepath,my_var)
% Then the function would work and define the name of the test file as:
% 'ver_str_value_my_var.mat' where my_var is the name of the my_var 
%  variable in the calling workspace
%  The routine can not be called e.g. as:
%>> check_matfile_IO (ver_var, true, filepath,my_var) as this will break the
% "inputname" function operations after ver_var variable.
%
for i=1:numel(varargin)
    class_name = class(varargin{i});
    arg_name = inputname(i+3);
    flname = [ver_str,'_',class_name,'_',arg_name,'.mat'];
    if save_variables
        eval([arg_name,' = varargin{i};']);
        try
            save(fullfile(tmp_dir,flname),arg_name);
        catch ME
            MEcause = MException('HORACE:_test:runtime_error', ...
                ['*** ERROR: Problem writing ',arg_name,' to ',flname]);
            ME.addCause(MEcause)
            rethrow(ME);
        end
    else
        tmp = load(fullfile(filepath,'saved_class_versions_as_mat_files',flname),arg_name);
        assertEqual(varargin{i},tmp.(arg_name), ...
            sprintf('*** ERROR: Argument %s read from %s does not match original',arg_name,flname));
    end
end
