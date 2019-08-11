classdef TestCaseWithSave < TestCase & oldTestCaseWithSaveInterface
    % Class to enable an xUnit-style unit test framework with tests against stored values
    %
    % This class extends the TestCase class with additional methods that enable
    % test results to be compared against previously stored values, or to save
    % test results as those stored values for future tests.
    %
    % The use of this class is similar to TestCase - for more details see the html
    % help pages for xUnit test framework <a href="matlab:web('Readme_xUnit.html');">here</a> and look at the "Advanced Usage"
    % section "How to Write xUnit-style Tests by Subclassing TestCase"
    %
    % Examples of test suites written using TestCaseWithSave will be opened in
    % your Matlab editor if you click on the following examples:
    %       <a href="matlab:edit('test_TestCaseWithSave_example_1');">test_TestCaseWithSave_example_1</a>
    %       <a href="matlab:edit('test_TestCaseWithSave_example_2');">test_TestCaseWithSave_example_2</a>
    %
    %
    % Creating a test suite
    % ---------------------
    % Create a test class that inherits TestCaseWithSave. This test class will
    % contain all the individual tests. Note that the name of the class must begin
    % with 'Test' or 'test':
    %
    % e.g.  classdef TestSomeStuff < TestCaseWithSave
    %
    % The properties block can contain any properties that are set up in the
    % method called setUp. These properties are available to each individual
    % test method in the class definition, and are recreated afresh for each
    % test method:
    %
    % e.g:      properties
    %               fig_handle
    %               data
    %           end
    %
    % The first method in the methods block is the constructor. it takes the
    % desired test method name as its input argument. The first line should
    % always initialise the superclass. Afterwards, include any properties
    % initialisations which will not be altered in any of the test methods.
    % This constructor will only be called once (despite the fact that it
    % takes a particular method name). Expensive operations such as reading
    % large data files for use as reference data are examples of what could
    % be done in the constructor. Always finish the method with the call to
    % the save method:
    %
    % e.g.      methods
    %               function self = TestSomeStuff(name)
    %               self@TestCaseWithSave(name);   % always the first line
    %                   :
    %               data = load('my_data_file.mat')
    %                   :
    %               self.save()     % always the last line
    %               end
    %
    % If you want to read stored reference results against which to test the
    % results of the test suite from a file other than the default file, then
    % give the name of the file in the second line:
    %
    % e.g.          function self = TestSomeStuff(name)
    %               self@TestCaseWithSave(name, filename);
    %                   :
    %
    % The setUp and tearDown methods can follow; these should setup any
    % properties that you want to re-create for each test method, and to clear
    % them afterwards. In this case, we want to recreate the property fig_handle
    % but the (expensively) loaded property data will be left untouched:
    %
    % e.g.          function setUp(self)
    %                   self.fig_handle = figure;
    %               end
    %
    %               function tearDown(self)
    %                   delete(self.fig_handle);
    %               end
    %
    % Now follows each test method. The name of each of the methods must
    % begin with 'test' or 'Test'. All the usual functions of the Matlab xUnit
    % test suite are available (assertTrue, assertEqual etc.) but in addition
    % there is the function assertEqualToTol which tests equality of arbitrarily
    % complex structures and objects with various further options to control the
    % test.
    %
    % The added feature of TestCaseWithSave is that the results can be saved
    % to disk and saved for later comparison. For example, in a test method that
    % calls assertEqualToTolWithSave, the test will be against a previously saved
    % value:
    %
    % e.g.          function testColormap(self)
    %                   sz = size(get(self.fh, 'Colormap'), 2);
    %                   assertEqualToTolWithSave(self,sz)
    %               end
    %
    %
    % Running a test suite
    % --------------------
    % The purpose of TestCaseWithSave is to allow easy saving and future testing
    % against of reference test results. The first thing you have to do is run
    % the test suite in 'save' mode to save the results of tests. Afterwards, you
    % can run the test suite in 'test' mode using the runtests function.
    %
    % - To save values run the test suite with the option '-save':
    %   ----------------------------------------------------------
    %       >> TestSomeStuff ('-save')                 % saves to default file name
    %   or: >> TestSomeStuff ('-save','my_file.mat')   % saves to the named file
    %
    %   The default file is <TestClassName>_output.mat in the temporary folder given
    %   by the Matlab function tempdir(). In this instance, our test suite is
    %   TestSomeStuff so the default is fullfile(tempdir,'TestSomeStuff_output.mat')
    %
    %   TIP: if you want to replace the test results for just one test, append
    %   the test name to the '-save' option. In this case:
    %       >> TestSomeStuff ('-save:testColormap')
    %   or: >> TestSomeStuff ('-save:testColormap','my_file.mat')
    %
    %
    % - To run the test suite testing against stored values
    %   ---------------------------------------------------
    %   Copy the file created above to the folder containing the test suite (in
    %   this case the test suite is in TestSomeStuff.m) and give it the default name
    %   <myTestSuite>_output.mat (so in this case the file is TestSomeStuff_output.mat).
    %   Then run the tests in  in the usual way as:
    %
    %       >> runtests TestSomeStuff                  % all test methods in the suite
    %       >> runtests TestSomeStuff:testColormap     % a specific test method
    %
    %
    % Additional methods
    % ------------------
    % It may be that in the constructor there are temporary files that are created
    % or paths that are added which are only for use only in the tests. The names
    % of the files or paths can be aaccumulated in any method of the class TestSomeStuff
    % (be that the constructor, utility methods you have written, or test methods -
    % but in this last case use cautiously):
    %
    % e.g.          function make_some_temporary_stuff(self)
    %                       :
    %                   add_to_files_cleanList (self, 'my_temp_file.txt')
    %                   add_to_path_cleanList (self, 'c:\temp')
    %                       :
    %               end
    %
    % NOTE: because the object is a handle object you do not need to return the object
    % because any changes to the object will be accessible anywhere else
    %
    %
    % TestCaseWithSave Methods:
    % --------------------------
    % The following methods are ones that can be used in a test suite
    %
    % Logical assertions:
    %   <a href="matlab:help('assertTrue');">assertTrue</a>                          - Assert that input condition is true
    %   <a href="matlab:help('assertFalse');">assertFalse</a>                         - Assert that input condition is false
    %   <a href="matlab:help('assertExceptionThrown');">assertExceptionThrown</a>               - Assert that specified exception is thrown
    %
    % Comparing two values:
    %   <a href="matlab:help('assertEqual');">assertEqual</a>                         - Assert that inputs are equal
    %   <a href="matlab:help('assertEqualToTol');">assertEqualToTol</a>                    - Assert that inputs are equal with a tolerance
    %   <a href="matlab:help('assertElementsAlmostEqual');">assertElementsAlmostEqual</a>           - Assert floating-point array elements almost equal
    %   <a href="matlab:help('assertVectorsAlmostEqual');">assertVectorsAlmostEqual</a>            - Assert floating-point vectors almost equal in norm sense
    %   <a href="matlab:help('assertFilesEqual');">assertFilesEqual</a>                    - Assert that files contain the same contents
    %
    % Comparing against a saved value:
    %   assertEqualWithSave                 - assert equality with saved variable
    %   assertEqualToTolWithSave            - assert near-equality with saved variable
    %   assertElementsAlmostEqualWithSave   - test floating array elements near-equality
    %   assertVectorsAlmostEqualWithSave    - test vector near-equality in L2 norm sense
    %   
    %
    % Utility methods:
    %   add_to_files_cleanList  - Add file or files to list to be deleted at end of test
    %   add_to_path_cleanList   - Add path or paths to list to be removed at end of test
    %
    %   delete_files            - Delete file or files that have been accumulated
    %                             with calls to add_to_files_cleanList
    %   remove_paths            - Remove path or paths that have been accumulated
    %                             with calls to add_to_path_cleanList
    %
    %   delete                  - Equivalent to performing delete_files and
    %                             remove_paths in succesion
    %
    %
    % TestCaseWithSave Properties:
    % -----------------------------
    %   ref_data                - Structure holding the reference test
    %                             results (test mode)
    %   test_results_file       - Name of the test results file that holds
    %                             the reference test results (test mode) or into
    %                             which test results will be saved (save mode)
    %   save_output             - If the test suite output is being saved or not
    %
    % It can be useful to know in a test method if the data is being saved, for example
    % if new output is being generated that would otherwise cause tests to fail. A
    % common case is with the assertion-without-save functions e.g. assertEqualToTol or
    % assertEqual. In this case, an error will be thrown and execution will cease. 
    
    
    % Original author A. Buts, rewritten T.G.Perring
    %
    % $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
    
    properties(Dependent)
        % Filename from which to read previously stored test results
        test_results_file
        
        % Structure containing the data to reference in tests or to store
        ref_data
    end
    
    properties (SetAccess=protected)
        % True if calculated data is to be saved in a temporary file
        save_output = false;
    end
    
    properties(Access=protected)
        % Structure containing test results
        % - If save_outptu is false (i.e. in test mode) the structure contains
        %   the contents of the file in test_results_file_, if it exists
        % - If save_output is true, it contains tests results to save in
        %   a temporary file whose name is constructed from test_results_file_
        ref_data_=struct();
        
        % Filename from which to read previously stored test results
        % This file name will also be used to construct the output file name
        % for saving results in save mode
        test_results_file_ = '';
        
        % Name of test method to be saved if save_output==true ({} means all methods)
        % If save_output is false, then this property is ignored
        test_method_to_save_ = {};
        
        % List of any files to delete after test suite is completed
        files_to_delete_= {};
        
        % List of any paths to remove after test suite is completed
        paths_to_remove_= {};
    end
    
    methods
        function this = TestCaseWithSave (opt, filename)
            % Construct your test class by inheriting this constructor:
            %
            %   function self = TestSomeStuff (name)
            %       self@TestCaseWithSave(name);
            %               :
            %       self.save()
            %   end
            %
            % *OR*
            %   function self = TestSomeStuff (name, ..., filename)
            %       self@TestCaseWithSave (name, filename)
            %               :
            %               :
            %       self.save()
            %   end
            %
            % When directly calling a test suite that has inherited TestCaseWithSave,
            % as opposed to using in the constructor for a test suite as above, then the
            % arguments are: (with myTestSuite as the name of an example test suite)
            %       myTestSuite('-save')
            %       myTestSuite('-save:testMethodName')  % to save output only for
            %                                            % a particular method
            %       myTestSuite('-save', filename)
            %       myTestSuite('-save:testMethodName', filename)
            %
            % Note: In a method of a test suite you can also cause the test results
            % to be saved rather than tested by calling
            %               :
            %       self@TestCaseWithSave('-save',filename);
            %               :
            % but this is not recommended.
            %
            %
            % In full:
            % ========
            %   >> obj = TestCaseWithSave (mode, filename)
            %
            % Input:
            % ------
            %  name_or_save In the constructor of a test suite that inherits
            %              TestCaseWithSave, then must be the name of the test suite
            %               If output is requested to be saved:
            %                   - '-save' if called from a test suite
            %                   - '-save:<testMethodName>' where testMethodName
            %                     is the name of one of the test methods in the
            %                    test suite
            %
            %               If TestCaseWithSave is being called directly, then
            %              no options can be given
            %
            % Optional:
            %   filename    Name of file that contains saved output against which
            %              values created in the test methods can be tested. Only
            %              needed if the file is different from the default value
            %              <myTestSuite>_output.mat in the folder containing
            %              <myTestSuite>. In this example the default file is
            %              'TestSomeStuff_output.mat'
            
            % This class constructor will be called by a sub-class constructor
            % - If that sub-class is used directly by the user, then the first argument
            %   can either be the name of the test suite, or a save option.
            % - The sub-class is also called from the xunit unit test suite. The way
            %   Alex Buts modified xunit and TestCase is such that the test suite name
            %   is what is passed.
            
            
            % Get the class name - we have no object yet, so must construct the name
            % (This will be the calling name of the test suite that has inherited
            % TestCaseWithSave, or will be TestCaseWithSave itself because it has been
            % directly invoked from the command line or within another function)
            class_name = mfilename('class');
            caller_is_test_suite = false;
            call_struct = dbstack(1);   % call stack starting from the caller function
            if numel(call_struct)>0
                cont=regexp(call_struct(1).name,'\.','split');
                if isTestCaseWithSaveSubclass_(cont{1})
                    class_name = cont{1};
                    caller_is_test_suite = true;
                end
            end
            
            % Create class with defaults
            this = this@TestCase(class_name);
            
            % Alter properties according to whether or not the class is a test suite
            if caller_is_test_suite
                % Update save_output and test methods to save, if necessary
                if nargin>=1    % option given
                    this = this.instantiate_methods_to_save_ (opt);
                end
                
                % Update test results file name and data structure
                if exist('filename','var')
                    this = this.instantiate_ref_data_ (filename);
                else
                    this = this.instantiate_ref_data_ ();
                end
                
            else
                % TestCaseWithSave called directly - no options allowed
                if nargin~=0
                    error('TEST_CASE_WITH_SAVE:invalid_argument',...
                        'Constructor called with invalid argument list')
                end
            end
        end
        
        %------------------------------------------------------------------
        function val = get.test_results_file(this)
            % Retrieve the name of the file, where the test results will be
            % stored
            val = this.test_results_file_;
        end
        
        function val = get.ref_data(this)
            % Retrieve the data to compare tests against
            val = this.ref_data_;
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
            
            this.files_to_delete_ = add_to_list (this.files_to_delete_, varargin{:});
        end
        
        %------------------------------------------------------------------
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
            
            this.paths_to_remove_ = add_to_list (this.paths_to_remove_, varargin{:});
        end
        
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
            % testing the variable against the stored value, the newly calculated variable
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
            %               For full details of keywords that control the comparison
            %              see <a href="matlab:help('equal_to_tol');">equal_to_tol</a>
            %              or class specific implementations of equal_to_tol, for example
            %              see <a href="matlab:help('equal_to_tol');">equal_to_tol</a>
            
            var_name = inputname(2);
            assertMethodWithSave (this, var, var_name, @assertEqualToTol, varargin{:},...
                'name_a',var_name,'name_b',[var_name,'_stored']);
        end
        
        function delete (this)
            % Function that will be called on destruction by virtue of the
            % class being a handle class
            
            % Use static utility methods
            this.delete_files (this.files_to_delete_)
            this.remove_paths (this.paths_to_remove_)
        end
    end
    
    
    %----------------------------------------------------------------------
    % Static methods
    %----------------------------------------------------------------------
    % These methods are used to delete files and paths in the destructor of
    % the class.
    % However, they have been made static methods so that they are also
    % available for general use in test suites
    
    methods(Static)
        %------------------------------------------------------------------
        function delete_files (varargin)
            % Delete file or files
            %
            %   testCaseWithSave.delete_files (files)
            %
            % files is a file name or cell array of file names
            
            if nargin== 1
                if ischar(varargin{1})
                    files={varargin{1}};
                elseif iscell(varargin{1})
                    files = varargin{1};
                end
            else
                files = varargin;
            end
            % Turn warnings off to prevent distracting messages
            warn = warning('off','all');
            % Delete files
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
        function remove_paths (varargin)
            % Remove path or paths
            %
            %   testCaseWithSave.remove_paths (paths)
            %
            % paths is a path name or cell array of path names
            
            if nargin== 1
                if ischar(varargin{1})
                    paths={varargin{1}};
                elseif iscell(varargin{1})
                    paths = varargin{1};
                end
            else
                paths = varargin;
            end
            % Turn warnings off to prevent distracting messages
            warn = warning('off','all');
            % Delete paths
            for i=1:numel(paths)
                rmpath(paths{i});
            end
            % Turn warnings back on
            warning(warn);
        end
        
    end
    
    
    %----------------------------------------------------------------------
    % Protected methods
    %----------------------------------------------------------------------
    methods(Access=protected)
        function assertMethodWithSave (this, var, var_name, funcHandle, varargin)
            % Wrapper to assertion methods to enable test or save functionality
            %
            %   >> assertMethodWithSave (this, var, var_name, funcHandle, varargin)
            %
            % Input:
            % ------
            %   var         Variable to test or save
            %   var_name    Name under which the variable will be saved
            %   funcHandle  Handle to assertion function
            %   varargin{:} Arguments to pass to assertion function, which must have
            %               the form e.g. assertVectorsAlmostEqual(A,B,varargin{:})
            
            % Get the name of the test method. Determine this as the highest
            % method of the class in the call stack that begins with 'test'
            % ignoring character case
            % (The test method may itself call functions in which the assertion
            % test is performed, which is why we need to search the stack to get
            % the test name)
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
            
            % Give default name for the variable if var_name is empty
            % (*** TGP 09/12/2018: this always enforces the default same name
            %  no matter how many other variables might have been previously saved.
            %  On the otherhand, this utlity routine always appears to be called
            %  with an explicit value for var_name, so thhis code block is not
            %  going to be called...)
            if isempty(var_name)
                var_name = [test_name,'_1'];
            end
            
            % Perform the test, or save
            if ~this.save_output
                stored_reference = this.get_ref_dataset_(var_name, test_name);
                funcHandle(var, stored_reference, varargin{:})
            else
                this.set_ref_dataset_ (var, var_name, test_name);
            end
        end
        
    end
end
