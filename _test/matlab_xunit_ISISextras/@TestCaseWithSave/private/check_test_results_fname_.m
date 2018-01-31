function filename = check_test_results_fname_(obj,filename)
% The method to check test results file name used in
% set.test_results_file method.
%
% In test mode it verifies that the test data file exist and fails
% if it does not.
%
% In save mode it verifies existence of the reference file, and
% if the reference file exist, changes the target save file
% location into tmp directory to keep existing file. If it does
% not exist and the class folder is writtable, sets the default
% target file path to class folder.
%


[fp,fn,fext] = fileparts(filename);
class_name = class(obj);
if isempty(fext)
    fext = '.mat';
    filename = fullfile(fp,[fn,fext]);
end
if obj.save_output
    % Saving output
    if exist(filename,'file')
        class_path = fileparts(which(class_name));
        if strcmpi(class_path,fp)
            filename = fullfile (tempdir(), [fn,fext]);
        end
    else
        test_dir =  fullfile(fp,'write_access_test_dir');
        clob = onCleanup(@()rmdir(test_dir,'s'));
        ok = mkdir(test_dir);
        if ok
            clear clob
        else
            filename = fullfile (tempdir(), [fn,fext]);
        end
    end
else
    if ~exist(filename,'file')
        warning('TEST_CASE_WITH_SAVE:runtime_error',...
            'file %s to load test results from does not exist',filename)
    end
end


