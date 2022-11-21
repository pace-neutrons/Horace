function check_matfile_IO (ver_str, save_variables, filepath,varargin)
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
% Outputs:
% Throws on assertEqual with error explaining the reason for failure 
%                   if the comparison with saved data is failed and
%                   returns successfully otherwise
%
% NOTE:
% for "inputname" function to work correctly, one needs to specify all
% inputs as variables, defined in the calling workspace.
% e.g. calling workspace needs to have
% ver_str = "ver_str_value" -- char value identifying the version;
% save_variables  = true;
% filepath= "some_path";
%  my_var = some_var_value where all assignments need to be present before 
%  call to the check_matfile_IO. The call then comes it in the
% form:
%>> check_matfile_IO (ver_var, save_var, filepath,my_var)
% Then the function would work and define the name of the test file as:
% 'ver_str_value_my_var.mat'
%  The routine can not be called as
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
