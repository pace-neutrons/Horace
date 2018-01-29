classdef TestCaseWithSave < TestCase
    % The class to run range of tests, united by common constructor
    % and set up by the same setUp and tearDown methods.
    % User needs to overload this class and add its own test cases, using
    % save_or_test_variables method.
    %
    % In additional to the standard TestCase, the class provides additional
    % functionality saving test results for later usage or loading previous
    % test results and comparing them against current test data.
    %
    % Usage of TestCaseWithSave child:
    %1)
    %>>runtests  TestCaseWithSave_child -- runs all unit tests stored in
    %                                     TestCaseWithSave_child and
    %                                     verifies their results against
    %                                     stored variables values.
    %2)
    %>>tc = TestCaseWithSave_child('-save');
    %>>tc.save();
    % The sequence above runs the tests but instead of comparing the
    % results against stored variables stores the variables specified
    % as inputs of save_or_test_variables method for later comparison
    % as in case 1)
    %
    % To achieve this functionality, user who overloads TestCaseWithSave
    % by writing his own test cases (methods, with names starting with test_)
    % should verify a test method results using the following methods:
    %
    %TestCaseWithSave Methods:
    %
    % save_or_test_variables - depending on mode of work verifies list of
    % variables provided as input against its saved counterparts (mode 1 above)
    % or saves these variables (mode 2 above).
    %
    %Auxiliary methods to use in TestCaseWithSave's child constructor:
    %add_to_files_cleanList - the files added using this function will
    %                         be deleted on the test class destruction.
    %add_to_path_cleanList  - the path added using this function will be
    %                         removed from Matlab search path on the test
    %                         class destruction.
    %
    %Note:
    % The files and paths added to clear list are deleted on the class
    % destructor execution. If you changed the class and want to invoke
    % the class constructor again, clear the previous class instance first
    % using Matlab clear "variable" command, where the "variable"
    % would be the old class instance.
    %
    % The destructor of the old class instance is invoked in random moment
    % of time which means that old files may be deleted after new files
    % were generated.
    %
    %
    % $Revision: 682 $ ($Date: 2018-01-14 19:54:54 +0000 (Sun, 14 Jan 2018) $)
    %
    properties(Dependent)
        % Filename for reading or writing test output for saving/comparing
        test_results_file;
        % structure, containing the data to store or reference in tests
        ref_data;
    end
    properties
        % default accuracy of the save_or_test_variables method
        tol = 1.e-8;        %
        
        % default parameters for equal_to_tol function used by
        % save_or_test_variables method. See equal_to_tol function for
        % other methods.
        comparison_par={'min_denominator', 0.01};
        %--- Auxiliary properties.
        % the string printed in the case of errors in
        % save_or_test_variables intended to provide additional information
        % about the error (usually set in front of save_or_test_variables)
        errmessage_prefix = ''
    end
    properties(SetAccess=protected,GetAccess=public)
        % True if calculated data is to be saved
        save_output = false;
    end
    
    properties(Access=protected)
        
        % List of the reference data aganst which to compare, or save
        ref_data_=struct();
        
        % Filename for reading or writing test output
        test_results_file_ = '';
        
        % Name of test method to be saved if save_output==true ({} means all methods)
        test_method_to_save_ = {};
        
        % List of files to delete after test case is completed
        files_to_delete_={};
        
        % List of paths to remove after test case is completed
        paths_to_remove_={};
        
    end
    
    methods
        function trf = get.test_results_file(obj)
            % retrieve the name of the file, where the test results will be
            % stored
            trf = obj.test_results_file_;
        end
        function ref_d = get.ref_data(obj)
            % retrieve the data to compare tests against
            ref_d = obj.ref_data_;
        end
        function set.test_results_file(obj,name)
            % verify if the test results file name is acceptable and refers
            % to allowed location and set this file and location as target
            % for test results
            check_and_set_test_results_file(obj,name);
        end
        function set.ref_data(obj,val)
            % retrieve the name of the file, where the test results will be
            % stored
            if isstruct(val)
                obj.ref_data_ = val;
            else
                error('TEST_CASE_WITH_SAVE:invalid_argument',...
                    'Reference data has to be a structure with the fields, containing the tests names')
            end
        end
        
        
        %------------------------------------------------------------------
        function this=TestCaseWithSave(varargin)
            % constructor. Overload it with your own test_ methods.
            % Usage:
            % tc = TestCaseWithSave_child({['-save'],'a [name']},[name_of_sr_file])
            %where
            % first parameter: -save or random name.
            % if random name, the testCaseWithSave_child would have this
            %                 name (used as helper in error messages)
            % if -save       : use this option to save test results into
            %                  test file name using save class method.
            % Second parameter (optional):
            % name_of_sr_file - name of the file to store or restore test
            %                   results. Sets up the property
            %                   results_filename and if not provided, the
            %                   default value of this property will be
            %                   used.
            %
            
            % do we have class name, used by standard unit test suite? ISIS
            % modified test suite does not construct multiple class
            % instances for each test method, though some peculiar or
            % manual scenario can still do this.
            if nargin > 0
                name = varargin{1};
                if nargin>1
                    argi = varargin{2:end};
                    if ~iscell(argi)
                        argi = {argi};
                    end
                else
                    argi = {};
                end
            else
                name= mfilename('class');
                argi = {};
            end
            % has option '-save' been provided
            if strcmpi(name,'-save')
                save_out=true;
            else
                save_out=false;
            end
            
            this = this@TestCase(name);
            this.save_output = save_out;
            
            % has filename with test data been provided?
            if numel(argi)>0
                fname  = build_default_test_results_filename_(class(this),argi{1});
            else
                fname = build_default_test_results_filename_(class(this));
            end
            % check if generated filename acceptable and possibly modify it
            % accordibng to -save operational modes. Warn if modification
            % is requered
            this.test_results_file=fname;
            
            
            % load old data if necessary
            % Load old data
            if ~this.save_output
                if exist(this.test_results_file,'file')
                    try
                        this.ref_data_ = load(this.test_results_file);
                    catch
                        error('TEST_CASE_WITH_SAVE:runtime_error',...
                            'Unable to read saved data from file: %s',filename)
                    end
                end
            end
            
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function delete (this)
            % Function that will be called on destruction by virtue of the
            % class being a handle class
            
            ws = warning('off');
            clob = onCleanup(@()warning(ws));
            % Use static utility methods
            this.delete_files (this.files_to_delete_)
            this.remove_paths (this.paths_to_remove_)
        end
        %------------------------------------------------------------------
        function this=add_to_files_cleanList (this, varargin)
            % Add names of files to be deleted once the test case is run
            %
            %   add_to_files_cleanList (this, file1, file2, ...)
            %
            % Utility method to use in subclass constructor to clean up
            % large temporary files that are created for the tests
            %
            % (Note that because the test class is a handle object, no
            % return argument is needed)
            
            this.files_to_delete_ = add_to_list_(this.files_to_delete_, varargin{:});
        end
        %
        function this=add_to_path_cleanList(this,varargin)
            % Add paths to be deleted once the test case is run
            %
            %   add_to_path_cleanList (this, path1, path2, ...)
            %
            % Utility method to use in subclass constructor to clean up
            % unwanted paths that are created for the tests
            %
            % (Note that because the test class is a handle object, no
            % return argument is needed)
            
            this.paths_to_remove_ = add_to_list_(this.paths_to_remove_, varargin{:});
        end
        
        %------------------------------------------------------------------
        % method to test input variable in varargin against saved
        % values or store these variables to the structure to save it
        % later (or deal with them any other way)
        %
        % Usage:
        %1)
        %>>tc = TestCaseWithSave_child(test_name,[reference_dataset_name])
        %>>tc.save_or_test_variables(a,b,c,['key1',value1,'key2',value2]);
        % First row loads reference variables 'a','b','c' from
        % the file with the name defined in reference_dataset_name. If
        % no name is provided, default class property value is used.
        % Second row compares these variables against their local values
        % stored in a,b,c variables.
        %
        % key-value arguments are the arguments, used by equal_to_tol
        % function. If no arguments are specified, default values are
        % constructed from the class properties.
        %
        % Acceptable keys currently are:
        % 'ignore_str','nan_equal','min_denominator','tol'
        %
        %2)
        %>>tc = TestCaseWithSave_child('-save')
        %>>tc.save_or_test_variables(a,b,c);
        % Saves the variables 'a','b','c' in the reference dataset to
        % compare against this dataset later (as in case 1)
        %
        % Any keys provided as input in this case stored into the
        % reference file as variables.
        %
        %
        this=save_or_test_variables(this,varargin)
        %------------------------------------------------------------------
        % Save output of the tests to file to test against later, if requested.
        %
        %   >> save (this)
        save (this)
        %------------------------------------------------------------------
        function assertEqualWithSave (this, var, varargin)
            % Assert that input and saved value are equal
            %
            %   assertEqualWithSave (this, var)
            %   assertEqualWithSave (this, var, message)
            %
            % Input:
            % ------
            %   this        test class object
            %   var         variable to be tested
            %
            % Optional:
            %   message     message to be prepended to the assertion message is the
            %               test fails
            %
            % This is the 'WithSave' extension of the xUnit unit test assertEqual
            %
            % See also assertEqual
            
            try
                assertMethodWithSave (this, var, inputname(2),...
                    @assertEqual, varargin{:});
            catch ME
                throwAsCaller (ME)
            end
        end
        
        %------------------------------------------------------------------
        function assertElementsAlmostEqualWithSave (this, var, varargin)
            % Assert floating-point array elements almost equal to saved array elements.
            %
            %   assertElementsAlmostEqualWithSave (this, var, tol_type, tol, floor_tol)
            %
            % Input:
            % ------
            %   this        test class object
            %   var         variable to be tested
            %   tol_type    Tolerance type: 'relative' or 'absolute'
            %   tol         Tolerance value
            %   tol_floor   Floor tolerance value
            %
            % Optional:
            %   message     message to be prepended to the assertion message is the
            %               test fails
            %
            % If the tolerance type is 'relative', then the tolerance test used is:
            %
            %       all( abs(var(:) - saved_var(:)) <= tol * max(abs(var(:)), abs(saved_var(:))) + floor_tol )
            %
            % If the tolerance type is 'absolute', then the tolerance test used is:
            %
            %       all( abs(var(:) - saved_var(:)) <= tol )
            %
            % This is the 'WithSave' extension of the xUnit unit test assertElementsAlmostEqual
            %
            % See also assertElementsAlmostEqual
            
            try
                assertMethodWithSave (this, var, inputname(2),...
                    @assertElementsAlmostEqual, varargin{:});
            catch ME
                throwAsCaller (ME)
            end
        end
        
        %------------------------------------------------------------------
        function assertVectorsAlmostEqualWithSave (this, var, varargin)
            % Assert floating-point vector is almost equal to saved vector in norm sense.
            %
            %   assertVectorsAlmostEqualWithSave (this, var, tol_type, tol, floor_tol)
            %
            % Input:
            % ------
            %   this        test class object
            %   var         variable to be tested
            %   tol_type    Tolerance type: 'relative' or 'absolute'
            %   tol         Tolerance value
            %   tol_floor   Floor tolerance value
            %
            % Optional:
            %   message     message to be prepended to the assertion message is the
            %               test fails
            %
            % If the tolerance type is 'relative', then the tolerance test used is:
            %
            %       all( norm(var - saved_var) <= tol * max(norm(var), norm(saved_var)) + floor_tol )
            %
            % If the tolerance type is 'absolute', then the tolerance test used is:
            %
            %       all( norm(var - saved_var) <= tol )
            %
            % This is the 'WithSave' extension of the xUnit unit test assertVectorsAlmostEqual
            %
            % See also assertVectorsAlmostEqual
            
            try
                assertMethodWithSave (this, var, inputname(2),...
                    @assertVectorsAlmostEqual, varargin{:});
            catch ME
                throwAsCaller (ME)
            end
        end
        
        %------------------------------------------------------------------
        function assertEqualToTolWithSave (this, var, varargin)
            % Test equality with stored value to within a tolerance, or save
            %   >> this = assertEqualToTolWithSave (this, var)
            %   >> this = assertEqualToTolWithSave (this, var, 'key1', val1, 'key2', val2, ...)
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
            
            var_name = inputname(2);
            try
                assertMethodWithSave (this, var, var_name, @assertEqualToTol, varargin{:},...
                    'name_a',var_name);
            catch ME
                throwAsCaller (ME)
            end
        end
    end
    %----------------------------------------------------------------------
    % Static methods
    %----------------------------------------------------------------------
    % These methods are used to delte files and paths in the destructor of
    % the class.
    % However, they have been made static methods so that they are also
    % available for general use in test suites
    methods(Static)
        %------------------------------------------------------------------
        function delete_files (files)
            % Delete file or files
            %
            %   testCaseWithSave2.delete_files (files)
            %
            % files is a file name or cell array of file names
            
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
            % Remove path or paths
            %
            %   testCaseWithSave2.remove_paths (paths)
            %
            % paths is a path name or cell array of path names
            
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
    %
    methods(Access = protected)
        function  assertMethodWithSave(this, var, var_name, funcHandle, varargin)
            % Wrapper to assertion methods to enable test or save functionality
            %
            %   >> assertMethodWithSave (this, var, var_name, funcHandle, varargin)
            %
            % Input:
            % ------
            %   var     Variable to test or save
            %   var_name    Name of variable under which it will be saved
            %   funcHandle  Handle to assertion function
            %   varargin{:} Arguments to pass to asserion function, which has
            %               the form e.g. assertVectorsAlmostEqual(A,B,varargin{:})
            
            class_name = class(this);
            call_struct = dbstack(1);
            for i=numel(call_struct):-1:2
                cont=regexp(call_struct(i).name,'\.','split');
                if strcmp(cont{1},class_name) && ~strcmp(cont{end},class_name) &&...
                        strncmpi(cont{end},'test',4)
                    test_name = cont{end};
                    break
                end
            end
            % Give default name if arg_name is empty
            if isempty(var_name)
                var_name = [test_name,'_1'];
            end
            % Perform the test, or save
            assert_or_save_variable_(this,var_name,var,funcHandle,varargin{:})
        end
        %
        function check_and_set_test_results_file(obj,name)
            % The method to check test results file name used in
            % set.test_results_file method. Made protected to allow child
            % classes to overload it.
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
            check_and_set_test_results_fname_(obj,name)
        end
    end
    
end
