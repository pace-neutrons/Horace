classdef TestCaseWithSave2 < TestCase
    % Create 
    %
    % TestCaseWithSave2 Methods:
    
    % The class to run range of tests, united by common constructor
    % and set up by the same setUp and tearDown methods.
    % User needs to overload this class and add its own test cases, using
    % save_or_test_variables method.
    %
    % In additional to the standard TestCase, the class provides additional
    % functionality saving test results for later usage or loading previous
    % test results and comparing them agains current test data.
    %
    % Usage of TestCaseWithSave child:
    %1)
    %>>runtests  TestCaseWithSave_child -- runs all unit tests stored in
    %                                     TestCaseWithSave_child and
    %                                     verifies their results against
    %                                     stored variables values.
    %2)
    %>>tc = TestCaseWithSave_child('save');
    %>>tc.save();
    % The sequence above runs the tests but instead of comparing the
    % results against stored variables stores the variables specified
    % as inputs of save_or_test_variables method for later comparison
    % as in case 1)
    %
    % To achieve this functionality, user who overloads TestCaseWithSave
    % by writing his own test cases (methods, with names starting with test_)
    % should verify a test method results using the following methods:
    %TestCaseWithSave Methods:
    %
    % save_or_test_variables - depending on mode of work verifies list of
    % variables provided as input against its saved counterparts or save
    % these variables if requested.
    %
    %Auxiliary methods to use in TestCaseWithSave's child constructor:
    %add_to_files_cleanList - the files added using this function will
    %                         be deleded on the test class destruction.
    %add_to_path_cleanList  - the path added using this funciton will be
    %                         removed from Matlab searh parh on the test
    %                         class destruction.
    %
    %Note:
    % The files and pathes added to clear list are deleted on the class
    % destructor execution. If you changed the class and want to issue
    % the class constructor againm, clear the previous class instance first
    % using Matlab clear variable command.
    % The destructor of the old class instance is invoked in random moment
    % of time which means that old files may be deleted after new files
    % were generated.
    
    
    % Original author A. Buts, rewritten T.G.Perring
    %
    % $Revision: 649 $ ($Date: 2017-11-01 19:42:04 +0000 (Wed, 01 Nov 2017) $)
    
    
    properties (SetAccess=private)
        % True if calculated data is to be saved
        save_output = false;
    end
    
    properties (Access=private)
        % List of the reference data aganst which to compare, or save
        ref_data_=struct();
        
        % List of files to delete after test case is completed
        files_to_delete_={};
        
        % List of paths to remove after test case is completed
        paths_to_remove_={};
    end
    
    methods
        function this = TestCaseWithSave2 (name, filename)
            % Construct the test
            %
            % Running the tests:
            %   >> this = TestCaseWithSave (name)
            %   >> this = TestCaseWithSave (name, file)
            %
            %   The default file name is <myTestClass>_output.mat in the
            %   folder that holds the subclass <myTestClass> which has
            %   all the tests
            %
            % Save test results:
            %   >> this = TestCaseWithSave ('-save')        % to default file
            %   >> this = TestCaseWithSave ('-save', file)  % to named file
            %
            %   The default file for output is <myTestClass>_output.mat in
            %   the temporary files folder returned by tempdir()
            
            % Create object
            if ischarstring(name)
                if ~strcmpi(name,'-save')
                    % No saving of output
                    save_output = false;
                else
                    % Save output from tests to file as reference datatsets for
                    % testing against in future running of the tests
                    % Need to get the name of the subclass with the tests. I
                    % do not know of anyway to get this except by creating an
                    % instance of the clsss and then gettng its name.
                    save_output = true;
                    name = '';
                end
            else
                error('Argument ''name'' must be a non-empty character string')
            end
            this = this@TestCase(name);
            this.save_output = save_output;
            
            % Load saved data, or save according value of save_output
            if ~save_output
                % Check name is the test class (if not '-save'): message that
                % the this superclass has been incorrectly used if not
                class_name = class(this);
                if ~strcmp(name,class_name)
                    error(['Invalid use of ',mfilename('class')])
                end
                
                % Construct file name to read from the input filename
                if exist('filename','var')
                    if ischarstring(filename) && exist(filename,'file')
                        if isempty(fileparts(filename))
                            filename = fullfile (fileparts(which(class_name)),...
                                filename);
                        end
                    else
                        error('Check stored data file name')
                    end
                else
                    % Construct default file name to read. If the default file
                    % doesn't exist this is not an error - it means that the 
                    % situation is that there is
                    % no request to a read a file and the file doesn't exist,
                    % so we are just using TestCaseWithSave like TestCase
                    filename = fullfile (fileparts(which(class_name)),...
                        [class_name,'_output.mat']);
                end
                
                % Load old data
                if exist(filename,'file')
                    try
                        this.ref_data_ = load(filename);
                    catch
                        error(['Unable to read saved data from file: ',filename])
                    end
                end
                
            else
                % Saving output
                if exist('filename','var')
                    save (this, filename);
                else
                    save (this);
                end
            end
        end
        
        %------------------------------------------------------------------
        function add_to_files_cleanList (this, varargin)
            % Add names of files to be deleted once the test case is run
            %
            %   >> add_to_files_cleanList (this, file1, file2, ...)
            %
            % Utility method to use in subclass constructor to clean up
            % large temporary files that are created for the tests
            %
            % (Note that because the test class is a handle object, no
            % return argument is needed)
            
            this.files_to_delete_ = add_to_list (this.files_to_delete_, varargin{:});
        end
        
        %------------------------------------------------------------------
        function add_to_path_cleanList(this,varargin)
            % Add paths to be deleted once the test case is run
            %
            %   >> add_to_path_cleanList (this, path1, path2, ...)
            %
            % Utility method to use in subclass constructor to clean up
            % unwanted paths that are created for the tests
            %
            % (Note that because the test class is a handle object, no
            % return argument is needed)

            this.paths_to_remove_ = add_to_list (this.paths_to_remove_, varargin{:});
        end
        
        %------------------------------------------------------------------
        function assertEqualWithSave (this, varargin)
            % Throw an exception if A is not equal to the stored value of A
            % assertEqual(this, B) throws an exception if A and B are not equal.  A and B
            % must have the same class and sparsity to be considered equal.
            % 
            % assertEqual(A, B, MESSAGE) prepends the string MESSAGE to the assertion
            % message if A and B are not equal.
        end
        
        %------------------------------------------------------------------
        function assertElementsAlmostEqualWithSave (this, varargin)
            % assertElementsAlmostEqual(A, B, tol_type, tol, floor_tol)
        end
        
        %------------------------------------------------------------------
        function assertVectorsAlmostEqualWithSave (this, varargin)
            % assertElementsAlmostEqual(A, B, tol_type, tol, floor_tol)
        end
        
        %------------------------------------------------------------------
        function assertEqualToTolWithSave (this, val, varargin)
            % Test equality with stored value to within a tolerance, or save
            %   >> this = assertEqualToTolWithSave (this, var)
            %   >> this = assertEqualToTolWithSave (this, var, 'key1', val1, 'key2', val2, ...)
            %   >> this = assertEqualToTolWithSave (..., message)
            %
            % When a test suite is launched with runtests, then if the test fails
            % a message is output to the screen.
            %
            % If the test class is run with the option '-save', then instead of
            % testing the variable against thestored value, the newly calculated variable
            % is saved to a file for future use as the stored value.
            %
            % Input:
            % ------
            %   var         Variable to test against stored values.
            %               The stored value is held in the object, having been
            %              loaded when the running of the test suite was started.
            %
            %  'key1',val1  Optional keywords and associated values. These control
            %              the tolerance and other parameters in the comparison.
            %               Valid keywords are:
            %                   'tol', 'reltol', abstol', 'ignore_str', 'nan_equal'
            %               For full details of keywords that control the comparsion
            %              see <a href="matlab:help('equal_to_tol');">equal_to_tol</a>
            %              or class specific implementations of equal_to_tol, for example
            %              see <a href="matlab:help('equal_to_tol');">equal_to_tol</a>
            %
            %   message     Optional string to prepend to the output assertion message

            
            % Parse the input arguments
            if rem(nargin,2)==1
                if is_string(varargin{end})
                    args=varargin(1:end-1);
                    message = varargin{end};
                else
                    error('Check number of arguments')
                end
            else
                args=varargin;
                message = '';
            end

            % Get the name of the calling method:
            call_struct = dbstack(1);
            if ~isempty(call_struct)
                cont=regexp(call_struct(1).name,'\.','split');
                test_name = cont{end};
            else
                test_name = '';     % interactive call
            end
            
            % Get name of variable
            % Give default name if namt passed as an actual variable in the caller
            val_name = inputname(2);
            if isempty(val_name)
                val_name = [test_name,'_1'];
            end
                    
            % Perform the test, or save
            if ~this.save_output
                ref_val = this.get_ref_dataset_(val_name, test_name);
                [ok, mess] = equal_to_tol (val, ref_val, args{:},...
                    'name_a', val_name, 'name_b', 'stored reference');
                if ~ok
                    if ~isempty(message)
                        message = [message,newline,mess];
                    else
                        message = mess;
                    end
                    throwAsCaller(MException('assertEqualToTolWithSave:tolExceeded', ...
                        '%s', message));
                end
            else
                this.set_ref_dataset_ (val, val_name, test_name)
            end
        end
        
        %------------------------------------------------------------------
        function save (this, filename)
            % Save output of the tests to file to test against later.
            %
            %   >> save (this)          % Save to default file
            %   >> save (this, file)    % Save to named file

            hc = herbert_config;
            if hc.log_level>-1
                disp('=========================================================================')
                disp(['    Save output from test class: ',class(this)])
                disp('=========================================================================')
            end
            
            % Find unit test methods (begin 'test' or 'Test', excluding the constructor)
            class_name = class(this);
            method_names = methods(this);
            idx = cellfun(@(x)((~isempty(regexp(x,'^test','once')) ||...
                ~isempty(regexp(x,'^Test','once'))) &&...
                ~strcmpi(x,class_name)), method_names);
            test_methods = method_names(idx);
            
            % Set save status to true
            this.save_output = true;
            
            % Clear reference data from possibly loaded previous datasets
            this.ref_data_ = struct();
            
            % Run test methods, when any test utilities that write to the
            % object will have comparison tests deactivated because
            % this.save_output is true
            for i=1:numel(test_methods)
                fhandle=@(x)this.(test_methods{i});
                this.setUp();   % ensure any setup method is called
                fhandle(this);
                this.tearDown();% ensure any teardown method is called
            end
            
            % Save data, if any has been returned
            if ~isempty(this.ref_data_)
                % Construct output filename
                if exist('filename','var')
                    if ischarstring(filename)
                        if isempty(fileparts(filename))
                            filename = fullfile (tempdir(), filename);
                        end
                    else
                        error('Check output file name')
                    end
                else
                    filename = fullfile (tempdir(), [class_name,'_output.mat']);
                end
                
                % Save results
                ref_data = this.ref_data_;
                save (filename, '-struct','ref_data')
                
                if hc.log_level>-1
                    disp(' ')
                    disp(['Output saved to: ',filename])
                    disp(' ')
                end
                
            else
                % No data to be saved
                disp(' ')
                disp(['No data to be saved from test class: ',class(this)])
                disp(' ')
            end
        end
        
        %------------------------------------------------------------------
        function delete (this)
            % Function that will be called on destruction by virtue of the
            % class being a handle class
            
            % Use static utility methods
            this.delete_files (this.files_to_delete_)
            this.remove_paths (this.paths_to_remove_)
        end
    end
    
    methods(Static)
        %------------------------------------------------------------------
        function delete_files (files)
            % Delete file or files (string or cell arrays of strings)
            
            % Turn warnings off to prevent distracting messages
            warn = warning('off','all');
            % Delete files
            if ischar(files)
                files={files};
            end
            for i=1:numel(files)
                if exist(files{i},'file')
                    try
                        delete(files{i});
                    catch
                    end
                end
            end
            % Turn warnings back on
            warning(warn);
        end
        
        %------------------------------------------------------------------
        function remove_paths (paths)
            % Remove path or paths (string or cell arrays of strings)
            
            % Turn warnings off to prevent distracting messages
            warn = warning('off','all');
            % Delete paths
            if ischar(paths)
                paths={paths};
            end
            for i=1:numel(paths)
                rmpath(paths{i});
            end
            % Turn warnings back on
            warning(warn);
        end
        
    end
    
    methods(Access=private)
        function var = get_ref_dataset_(this, var_name, test_name)
            % Retrive variable from the store for the named test
            %
            % Input:
            % ------
            %   var_name    -- the name opf the variable to retrieve
            %   test_name   -- the name of the test the variable belongs to
            %
            % Outut:
            % ------
            %   var         -- retrieved variable
            %
            % NOTE: for backwards compatibiity with earlier versions:
            % If the variable is not found in the structure for the named
            % test it is looked for at the top level of the class property
            % ref_data_.
            
            if isfield(this.ref_data_,test_name) && isstruct(this.ref_data_.(test_name))
                % Structure called test_name exists - assume new format
                S = this.ref_data_.(test_name);
                if isfield(S,var_name)
                    var = S.(var_name);
                else
                    error('TestCaseWithSave:invalid_argument',...
                        'variable: %s does not exist in stored data for the test: %s',...
                        var_name,test_name);
                end
            else
                % No structure called test_name exists - assume old format
                if isfield(this.ref_data_,var_name)
                    var = this.ref_data_.(var_name);
                else
                    error('TestCaseWithSave:invalid_argument',...
                        'variable: %s does not exist',...
                        var_name);
                end
            end
        end
        
        %------------------------------------------------------------------
        function this = set_ref_dataset_(this, var, var_name, test_name)
            % Save a variable to the store for the named test
            %
            % Input:
            % ------
            %   var         -- variable to store
            %   var_name    -- the name by which to save the variable
            %   test_name   -- the name of the test with which to associate
            %                  the saved variable
            %
            % The variable will be saved in
            %   this.ref_data_.(test_name).(var_name)
            
            % Get store area of named test, or create if doesnt exist
            if isfield(this.ref_data_,test_name)
                S = this.ref_data_.(test_name);
            else
                S = struct();
            end
            S.(var_name) = var;
            this.ref_data_.(test_name) = S;
        end
        
    end
end

%--------------------------------------------------------------------------
% Utility functions for internal use
%--------------------------------------------------------------------------
function new_list = add_to_list (initial_list, varargin)
% Append character strings to a cell array of strings
%
%   >> new_list = add_to_list (initial_list, str1, str2, ...)
%
% Only the first occurence of new strings is appended, and then only if
% it doesn't appear in the initial list.
%
% Input:
% ------
%   initial_list    Row cell arrayof character strings
%   str1, str2,...  Can be strings or cell arrays of strings
%
% Output:
% -------
%   new_list        Row cell array with unique instances

for i=1:numel(varargin)
    str = varargin{i};
    if ischar(str) && numel(size(str))==2
        varargin{i} = {str};
    elseif iscellstr(str)
        varargin{i} = varargin{i}(:)';
    else
        error('Not all arguments are strings or cell arrays of strings')
    end
end

add_list = cat(2,varargin{:});  % make one long row
if ~isempty(add_list)
    [~,ix] = unique(add_list,'first','legacy');
    add_list = add_list(sort(ix));
    new=~ismember(add_list,initial_list);
    new_list = [initial_list,add_list(new)];
else
    new_list = initial_list;
end

end


%--------------------------------------------------------------------------
function ok = ischarstring (x)
ok = (ischar(x) && numel(size(x))==2 && size(x,1)==1 && size(x,2)>0);
end


%--------------------------------------------------------------------------
function [ok,n] = is_string(varargin)
% true if variable is a character string i.e. 1xn character array (n>=0), or empty character
%
%   >> ok = is_string (var)             % true or false
%   >> ok = is_string (var1, var2,...)  % logical row vector
%   >> [ok,n] = is_string (...)         % n is number of caharvers (NaN if not a string)
%
% Note: if var is empty but has size 1x0 then will return true
%       Also, if empty, will return true

isstr = @(a)(ischar(a) && ((numel(size(a))==2 && size(a,1)==1) || isempty(a)));

if nargin==1
    ok = isstr(varargin{1});    
    if ok
        n = numel(varargin{1});
    else
        n = NaN;
    end
elseif nargin>1
    ok = cellfun(isstr, varargin);
    n = NaN(size(varargin));
    n(ok) = cellfun(@numel,varargin(ok));
else
    ok = false(1,0);
    n = NaN(1,0);
end

end
