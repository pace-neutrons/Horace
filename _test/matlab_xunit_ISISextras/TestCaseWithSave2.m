classdef TestCaseWithSave2 < TestCase
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
    %
    % Creating a test suite
    % ---------------------
    % Create a test class that inherits testCaseWithSave2. This test class  will
    % contain all the individual tests:
    %
    % e.g.  classdef myTest < TestCaseWithSave2
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
    % desired test method name as its input argument. Include any properties
    % initialisations which will not be altered in any of the test methods.
    % This constructor will only be called once (despite the fact that it
    % takes a particular method name). Expensive operations such as reading
    % large data files for use as reference data are examples of what could
    % be pdone in the constructor:
    %
    % e.g.      methods
    %               function self = myTest(name)
    %               self@TestCaseWithSave2(name);
    %
    %               data = load('my_data_file.mat')
    %                   :
    %               end
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
    % Now have each test method. All the usual functions of the matlab xUnit
    % test suite are available (assertTrue, assertEqual etc.) but in addition
    % there is the function assertEqualToTol which tests equality of arbitraryily
    % complex structures and objects with various further options to control the
    % test.
    %
    % The added feature of TestCaseWithSave2 is that the results can be saved
    % to disk and saved for later comparison. For example, in a test method that
    % calls assertEqualToTolWithSave, the test will be against a previously saved
    % value:
    %
    % e.g.          function testColormap(self)
    %                   sz1 = size(get(self.fh, 'Colormap'), 2);
    %                   assertEqualToTolWithSave(self,sz1)
    %               end
    %
    %
    % Running a test suite
    % --------------------
    % - To save values run the test suite with the option '-save':
    %   ----------------------------------------------------------
    %       >> myTest ('-save')                 % saves to default file name
    %   or: >> myTest ('-save','my_file.mat')   % saves to the named file
    %
    %   The default file is <myTestClass>_output.mat in the temporary folder given
    %   by the matlab function tempdir(). In this instance, our test suite is myTest
    %   so the default file is fullfile(tempdir,'myTest_output.mat')
    %
    %
    % - To run the test suite testing against stored values
    %   ---------------------------------------------------
    %   Copy the file created above to the folder containing the test suite (in
    %   this case the test suite is in myTest.m) and give it the default name
    %   <myTestSuite>_output.mat (so in this case the file is myTest_output.mat).
    %   Then run the tests in  in the usual way as:
    %
    %       >> runtests myTest                  % all test methods in the suite
    %       >> runtests myTest:testColormap     % a specific test method
    %
    %
    % Additional methods
    % ------------------
    % It may be that in the constructor there are temporary files that are created
    % or paths that are added which are only for use only in the tests. The names
    % of the files or paths can be aaccumulated in any method of the class myTest
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
    % because any changes to the object will be accesible anywhere else
    %
    %
    % TestCaseWithSave2 Methods:
    % --------------------------
    % The following methods are ones that will be used in a test suite
    %
    % To perform tests:
    %   assertEqualToTolWithSave            - assert near-equality with saved variable
    %   assertEqualWithSave                 - assert equality with saved variable
    %   assertElementsAlmostEqualWithSave   - test floating array elements near-equality
    %   assertVectorsAlmostEqualWithSave    - test vector near-equality in L2 norm sense
    %
    % Utilities:
    %   add_to_files_cleanList  - add file or files to list to be deleted at end of test
    %   add_to_path_cleanList   - add path or paths to list to be removed at end of test
    %
    %   delete_files            - delete file or files
    %   remove_paths            - remove path or paths
    %
    %
    % TestCaseWithSave2 Properties:
    % -----------------------------
    %   save_output             - if the test suite output is being saved or not
    %
    % It can be useful to know in a test method if the data is being saved for example
    % if new output is being generated that would wotherwise cause tests to fail. A
    % common case is with the assertion-witout-save functions e.g. assertEqualToTol or
    % assertEqual. In this case, an error will be thrown and execution will cease.
    %
    %
    %
    % See also assertEqualToTol assertEqual assertElementsAlmostEqual assertVectorsAlmostEqual
    % assertFilesEqual
    % assertTrue assertFalse assertExceptionThrown
    
    
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
            % Construct your test class by inheriting this constructor:
            %
            %   function self = myLittleTest (name)
            %               :
            %       self@TestCaseWithSave2 (name);
            %    OR
            %       self@TestCaseWithSave2 (name, file)
            %               :
            %
            % Input:
            % ------
            %   name        Name of test suite or test method in the suite
            %              Actually, you do not need to worry about this argument,
            %              as it is passed from the xUnit test suite. Just use it
            %              blindly!
            % Optional:
            %   filename    Name of file that contains saved output against which
            %              values created in the tes methods can be testsed. Only 
            %              needed if the file is other than the default value
            %              <myTestSuite>_output.mat in the folder containing
            %              <myTestSuite>. In this example the default file is
            %              'myLittleTest_output.mat'
                
            % Get the default name: the calling TestCase subclass, if one, or else this class
            name_default = mfilename('class');
            call_struct = dbstack(1);
            if numel(call_struct)>0
                cont=regexp(call_struct(1).name,'\.','split');
                if isTestCaseWithSave2Subclass(cont{1})
                    name_default = cont{1};
                end    
            end
            
            % Create object
            if exist('name','var')
                if ischarstring(name) && isvarname(name)
                    % Valid name and no saving of output
                    save_output = false;
                elseif ischarstring(name) && strcmpi(name,'-save')
                    % Save output from tests to file as reference datatsets for
                    % testing against in future running of the tests
                    % Need to get the name of the subclass with the tests. I
                    % do not know of anyway to get this except by creating an
                    % instance of the clsss and then gettng its name.
                    save_output = true;
                    name = name_default;
                else
                    error('Argument ''name'' must be a non-empty character string')
                end
            else
                save_output = false;
                name = name_default;
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
        function add_to_path_cleanList(this,varargin)
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
            
            var_name = inputname(2);
            try
                assertMethodWithSave (this, var, var_name, @assertEqualToTol, varargin{:},...
                    'name_a',var_name);
            catch ME
                throwAsCaller (ME)
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
    
    
    %----------------------------------------------------------------------
    % Private methods
    %----------------------------------------------------------------------
    methods(Access=private)
        function assertMethodWithSave (this, var, var_name, funcHandle, varargin)
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
            
            % Get the name of the test method. Determine this as the highest
            % method of the class in the call stack that begins with 'test'
            % ignoring case
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
            if ~this.save_output
                stored_reference = this.get_ref_dataset_(var_name, test_name);
                funcHandle(var, stored_reference, varargin{:})
            else
                this.set_ref_dataset_ (var, var_name, test_name)
            end
        end
        
        %------------------------------------------------------------------
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
function tf = isTestCaseWithSave2Subclass(name)
%isTestCaseWithSave2Subclass True for name of a TestCaseWithSave2 subclass
%   tf = isTestCaseWithSave2Subclass(name) returns true if the string name is the name of
%   a TestCase subclass on the MATLAB path.
%
% Code is a copy of isTestCaseSubclass from the matlab xUnit test suite by
% Steven L. Eddins, (see below), with the name of the superclass changed
%
%   Steven L. Eddins
%   Copyright 2008-2009 The MathWorks, Inc.

tf = false;

class_meta = meta.class.fromName(name);
if isempty(class_meta)
    % Not the name of a class
    return;
end

if strcmp(class_meta.Name, 'TestCaseWithSave2')
    tf = true;
else
    tf = isMetaTestCaseSubclass(class_meta);
end

end

function tf = isMetaTestCaseSubclass(class_meta)

tf = false;

if strcmp(class_meta.Name, 'TestCaseWithSave2')
    tf = true;
else
    % Invoke function recursively on parent classes.
    super_classes = class_meta.SuperClasses;
    for k = 1:numel(super_classes)
        if isMetaTestCaseSubclass(super_classes{k})
            tf = true;
            break;
        end
    end
end

end

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
