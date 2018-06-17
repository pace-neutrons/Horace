classdef TestCaseWithSave2_work < TestCaseWithSave
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
    % Create a test class that inherits TestCaseWithSave2. This test class will
    % contain all the individual tests. Note that the name of the class must begin
    % with 'Test' or 'test':
    %
    % e.g.  classdef TestSomeStuff < TestCaseWithSave2
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
    %               self@TestCaseWithSave2(name);   % always the first line
    %                   :
    %               data = load('my_data_file.mat')
    %                   :
    %               self.save()     % always the last line
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
    % Now follows each test method. The name of each of the methods must
    % begin with 'test' or 'Test'. All the usual functions of the Matlab xUnit
    % test suite are available (assertTrue, assertEqual etc.) but in addition
    % there is the function assertEqualToTol which tests equality of arbitrarily
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
    %       >> TestSomeStuff ('-save')                 % saves to default file name
    %   or: >> TestSomeStuff ('-save','my_file.mat')   % saves to the named file
    %
    %   The default file is <TestClassName>_output.mat in the temporary folder given
    %   by the matlab function tempdir(). In this instance, our test suite is
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
    % if new output is being generated that would otherwise cause tests to fail. A
    % common case is with the assertion-without-save functions e.g. assertEqualToTol or
    % assertEqual. In this case, an error will be thrown and execution will cease.
    %
    %
    %
    % See also assertEqualToTol assertEqual assertElementsAlmostEqual assertVectorsAlmostEqual
    % assertFilesEqual
    % assertTrue assertFalse assertExceptionThrown
    
    
    % Original author A. Buts, rewritten T.G.Perring
    %
    % $Revision$ ($Date$)
    
    methods
        function this = TestCaseWithSave2_work (name,varargin)
            % Construct your test class by inheriting this constructor:
            %
            %   function self = TestSomeStuff (name)
            %       self@TestCaseWithSave2 (name);
            %               :
            %       self.save()
            %   end
            %
            % *OR*
            %   function self = TestSomeStuff (name, ..., filename)
            %       self@TestCaseWithSave2 (name, filename)
            %               :
            %               :
            %       self.save()
            %   end
            %
            % Input:
            % ------
            % Optional:
            %   name        One of:
            %               - name of the calling test suite.
            %               - '-save' if called from a test suite
            %               - '-save:<testMethodName>' where testMethodName
            %                   is the name of one of the test methods in the
            %                   test suite
            %
            %              Actually, you do not need to worry about this argument,
            %              as it is passed from the xUnit test suite. Just use it
            %              blindly!
            %
            %   filename    Name of file that contains saved output against which
            %              values created in the test methods can be tested. Only
            %              needed if the file is different from the default value
            %              <myTestSuite>_output.mat in the folder containing
            %              <myTestSuite>. In this example the default file is
            %              'TestSomeStuff_output.mat'
            
            % - If the call is made from a test suite, then name will be the name of the
            %   test suite (that is how Alex Buts' modification of TestCase works)
            % -
            
            % Get the default name: the calling TestCase subclass, if one, or else this class
            name_default = mfilename('class');
            caller_is_test_suite = false;
            call_struct = dbstack(1);
            if numel(call_struct)>0
                cont=regexp(call_struct(1).name,'\.','split');
                if isTestCaseWithSave2Subclass(cont{1})
                    name_default = cont{1};
                    caller_is_test_suite = true;
                end
            end
            
            % Create object
            if exist('name','var')
                if is_string(name)
                    if strcmpi(name,name_default)
                        % Either this class, or test suite class, and no saving of output
                        save_output = false;
                    elseif caller_is_test_suite && strcmpi(name,'-save')
                        % Save output from tests to file as reference datasets for
                        % testing against in future running of the tests
                        save_output = true;
                        test_method_to_save = {};   % means all methods
                    elseif caller_is_test_suite && strncmpi(name,'-save:',6) &&...
                            numel(name)>6
                        save_output = true;
                        test_method_to_save = name(7:end);
                    else
                        error(['Argument ''',name,''' is invalid'])
                    end
                else
                    error(['Argument ''',name,''' must be a non-empty character string'])
                end
                argi = varargin{2:end};
            else
                save_output = false;
                name = name_default;
                argi = {};
            end
            this = this@TestCaseWithSave(name,argi{:});            

            this.save_output = save_output;
            
            % Determine which test methods to save
            if save_output
                if isempty(test_method_to_save)
                    this.test_method_to_save_ = {};
                else
                    test_methods = getTestMethods(this);
                    idx = find(strcmpi(test_method_to_save,test_methods));
                    if ~isempty(idx)
                        this.test_method_to_save_ = test_methods(idx);
                    else
                        error(['Unrecognised test method to save: ''',test_method_to_save,''''])
                    end
                end
            end
        end
        
        %------------------------------------------------------------------
        
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

if strcmp(class_meta.Name, 'TestCaseWithSave2_work')
    tf = true;
else
    tf = isMetaTestCaseSubclass(class_meta);
end

end

function tf = isMetaTestCaseSubclass(class_meta)

tf = false;

if strcmp(class_meta.Name, 'TestCaseWithSave2_work')
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



