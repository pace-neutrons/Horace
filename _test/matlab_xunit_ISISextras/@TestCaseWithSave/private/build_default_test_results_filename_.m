function  fname = build_default_test_results_filename_(class_name,filename)
% Construct file name and location to read/write the test results data
%
if exist('filename','var')
    if is_string(filename)
        if isempty(fileparts(filename))
            fname = fullfile (fileparts(which(class_name)),...
                filename);
        else
            fname  = filename;
        end
    else
        error('TEST_CASE_WITH_SAVE:invalid_argument',...
            ' The name of file to read/write test results should be a string but it is not')
    end
else
    % Construct default file name to read. If the default file
    % doesn't exist this is not an error - it means that the
    % situation is that there is
    % no request to a read a file and the file doesn't exist,
    % so we are just using TestCaseWithSave like TestCase
    fname = fullfile (fileparts(which(class_name)),...
        [class_name,'_output.mat']);
end
