function filename = check_test_performance_fname_(filename)
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
if isempty(fext)
    fext = '.xml';
    filename = fullfile(fp,[fn,fext]);
end
test_dir =  fullfile(fp,'write_access_test_dir');
clob = onCleanup(@()rmdir(test_dir,'s'));
ok = mkdir(test_dir);
if ok
    clear clob
else
    filename = fullfile (tempdir(), [fn,fext]);
end




