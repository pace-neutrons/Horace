function this = instantiate_ref_data_ (this, filename)
% Set the name of the test file name and read stored data, if any
%
%   >> this = instantiate_ref_data_ (this)
%   >> this = instantiate_ref_data_ (this, filename)
%
% This function does not fail if a file holding saved data does not exist.
% It could simply be that no results have been stored because we are just
% using TestCaseWithSave like TestCase


class_name = class(this);
default_test_file_name = fullfile (fileparts(which(class_name)),...
    [class_name,'_output.mat']);    % Default name for holding test results in test mode

if ~this.save_output
    % In test operation (i.e. testing against pre-stored data, if any)
    if exist('filename','var')
        % Check test results file name
        if ischarstring(filename)
            [fpath,~,fext] = fileparts(filename);
            if isempty(fpath)
                filename = fullfile (fileparts(which(class_name)),...
                    filename);
            end
            if isempty(fext)
                filename = [filename,'.mat'];
            end
        else
            error('TEST_CASE_WITH_SAVE:invalid_argument',...
                ' The name of file from which to read test results must be a non-empty character string')
        end
    else
        filename = default_test_file_name;
    end
    
    
    % Store the test file name which will contain stored tests, even if it
    % doesn't exist.
    this.test_results_file_ = filename;
    
    % Read in stored data, if there is a pre-existing test results file
    if exist(filename,'file')
        this.ref_data_ = load(filename);
    end
    
else
    % In save operation i.e. storing recalculated output for one or all tests
    
    % Create file name for saving results, checkng that the file is not the same as the
    % default filename for containng data against which to test in the test suite
    if exist('filename','var')
        if ischarstring(filename)
            [fpath,~,fext] = fileparts(filename);
            if isempty(fpath)
                filename = fullfile (tempdir(), filename);
            end
            if isempty(fext)
                filename = [filename,'.mat'];
            end
        else
            error('TEST_CASE_WITH_SAVE:invalid_argument',...
                ' The name of file to which to write test results must be a non-empty character string')
        end
    else
        filename = fullfile (tempdir(), [class_name,'_output.mat']);
    end
    
    % Check that the output folder is not write protected
    [folder,fn,fe] = fileparts(filename);
    if ~isOkToWriteTo (folder)
        warning('TEST_CASE_WITH_SAVE:runtime_error',...
            ' Write protected test folder: %s; using tempdir folder',folder)
        if exist(filename,'file') == 2
            copyfile(filename,tempdir,'f');
        end
        filename = fullfile(tempdir,[fn,fe]);
    end
    
    % Store the file name into which to save tests, even if it
    % doesn't exist.
    this.test_results_file_ = filename;
    
end
