classdef TestCaseWithSave2 < TestCase
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
    %
    %
    % $Revision: 649 $ ($Date: 2017-11-01 19:42:04 +0000 (Wed, 01 Nov 2017) $)
    %
    properties
        % Make get access only
        % --------------------
        % true if we want to save test results and true if save them as example
        % to test against it later.
        want_to_save_output = false;
        
        % Make private
        % ------------
        % list of the reference (restored) datasets one comapres against
        % or the datasets one intends to save.
        ref_data=struct();
        
        
        
        % Can get rid of
        %---------------
        % Folder where results are stored and saved
        % The default is that saved results are read from the folder where
        % the test folder, and saved to the temporary folder as given by
        % the matlab function tempdir.
        results_path ='';
        
        % The name of the file to store/restore sample test result
        results_filename = 'results_to_compare_with.mat';
        
        
        
        
        
        
        % default parameters for equal_to_tol function used by
        % save_or_test_variables method. See equal_to_tol function for
        % other methods.
        comparison_par={'min_denominator', 0.01};
        
        % default accuracy of the save_or_test_variables method
        tol = 1.e-8;
        
        %--- Auxiliary properties.
        
        
        % Prefix to error message if test fails
        errmessage_prefix = ''
    end
    
    properties (Access=private)
        % List of files to delete after test case is completed
        files_to_delete_={};
        
        % List of paths to remove after test case is completed
        paths_to_remove_={};
    end
    
    methods
        function this=TestCaseWithSave2(varargin)
            % Construct the test
            %
            %   >> this = TestCaseWithSave (name)
            %   >> this = TestCaseWithSave (name, file)
            
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
            
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@TestCase(name);
            
            
            if nargin>1
                inputFile = varargin{2};
                [this.results_path,this.results_filename]=fileparts(inputFile);
            else
                this.results_path=fileparts(mfilename('fullpath'));
                inputFile = fullfile(this.results_path,this.results_filename);
            end
            if strcmpi(name,'-save')
                this.want_to_save_output=true;
            else
                this.want_to_save_output=false;
            end
            
            
            
            % load old data if necessary
            if not(this.want_to_save_output) && exist(inputFile,'file')
                this.ref_data=load(inputFile);
            end
            
        end
        
        
        
        %------------------------------------------------------------------
        function this = add_to_files_cleanList (this, varargin)
            % Add names of files to be deleted once the test case is run
            %
            %   >> add_to_files_cleanList (this, file1, file2, ...)
            %
            % (Note that because the test class is a handle object, no
            % return argument is needed)
            
            this.files_to_delete_ = add_to_list (this.files_to_delete_, varargin{:});
        end
        
        %------------------------------------------------------------------
        function this=add_to_path_cleanList(this,varargin)
            this.paths_to_remove_= add_data_to_list(this.paths_to_remove_,varargin{:});
        end
        
        %------------------------------------------------------------------
        function this=save_or_test_variables(this,varargin)
            % method to test input variable in vararging agains saved
            % values or store these variables to the structure to save it
            % later (or deal with them any other way)
            % Usage:
            %1)
            %>>tc = TestCaseWithSave_child(test_name,[reference_dataset_name])
            %>>tc.save_or_test_variables(a,b,c,['key1',value1,'key2',value2]);
            % First row loads reference variables 'a','b','c' from
            % the file with the name defined in reference_dataset_name. If
            % no name is provided, default class property value is used.
            % Second row compares these variables agains their local values
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
            % get the names of the workspaces to test
            %
            keys = {'ignore_str','nan_equal','min_denominator','tol'};
            % process input arguments, extract workspaces and set up
            % default class values for arguments which are not provided
            [keyval,ws_list,toll] = process_inputs_(this,keys,varargin{:});
            
            
            % get the name of the calling method:
            call_struct = dbstack(1);
            cont=regexp(call_struct(1).name,'\.','split');
            if numel(cont) > 1
                test_name = cont{end};
            else
                test_name = cont{1};
            end
            if isempty(test_name)
                test_name  = 'interactive';
            end
            % get the names of the workspaces to test
            % assign default names to workspaces, which are the part of
            % array or do not have a name for other reason
            ws_names = cell(numel(ws_list),1);
            for i = 1:numel(ws_list)
                ws_names{i} = inputname(i+1);
                if isempty(ws_names{i})
                    ws_names{i} = [test_name,'_ws_N_',num2str(i)];
                end
            end
            
            
            % process test results and either compare it against restored
            % earlier variables or set up for saving them later.
            for i=1:numel(ws_list)
                if not(this.want_to_save_output)
                    ref_dataset = this.get_ref_dataset_(ws_names{i},test_name);
                    % HACK -- see sort method description
                    if this.sort_pixels
                        [ws_sort,ref_ws_sort] = TestCaseWithSave.sort_ws_pixels(ws_list{i},ref_dataset);
                        [ok,mess]=equal_to_tol(ws_sort, ref_ws_sort,toll,keyval{:});
                    else
                        [ok,mess]=equal_to_tol(ws_list{i}, ref_dataset,toll,keyval{:});
                    end
                    
                    assertTrue(ok,[this.errmessage_prefix,': [',inputname(i+1),'] :',mess])
                else
                    this = this.set_ref_dataset_(ws_list{i},ws_names{i},test_name);
                end
            end
        end
        
        %------------------------------------------------------------------
        function save(this)
            % Method to save output of the test files to the file to test
            % against it later.
            %
            % the file to save is defined by class property value results_filename
            % and the datasets should be defined using save_or_test_variables
            % method
            %
            hc = herbert_config;
            if hc.log_level>-1
                disp('===========================')
                disp('    Save output')
                disp('===========================')
            end
            meth=methods(this);
            ometha = metaclass(this);
            class_name = ometha.Name;
            % select the methods which are the tests among all test methods
            istests = cellfun(@(x)( ~isempty(regexp(x,'^test_','once')) && ~strcmpi(x,class_name)),meth);
            test_methods=meth(istests);
            % indicate that you want to store results of the test rather
            % then testing them against results, saved earlier.
            % Check for that is in save_or_test_variables
            this.want_to_save_output=true;
            %
            % clear reference data from possibly loaded previous datasets
            this.ref_data = struct();
            % run test methods using save_or_test_variables store data
            % instead of comparing them with reference datasets
            for i=1:numel(test_methods)
                fh=@(x)this.(test_methods{i});
                this.setUp();
                fh(this);
                this.tearDown();
            end
            
            % save results
            if isempty(this.results_path)
                output_file=fullfile(tempdir(),this.results_filename);
            else
                output_file=fullfile(this.results_path,this.results_filename);
            end
            %
            dsts=this.ref_data;
            save(output_file,'-struct','dsts')
            
            if hc.log_level>-1
                disp(' ')
                disp(['Output saved to ',output_file])
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
        function [keyval,ws_list,toll]=process_inputs_(this,keys_array,varargin)
            % provess input arguments, separate control keys from workspaces
            % and set up default values for keys, which are not present
            %
            [keyval,ws_list] = extract_keyvalues(varargin,keys_array);
            if numel(ws_list) == 0
                return;
            end
            
            % function decides if the variable equal to tol
            f_tol_present = @(var)(is_string(var)&&strcmp(var,'tol'));
            % check if var 'tol' among the input arguments
            tol_provided = cellfun(f_tol_present,keyval);
            if any(tol_provided)
                itol = find(tol_provided);
                toll = keyval{itol+1};
                tol_provided(itol+1)=true;
                keyval = keyval(~tol_provided);
            else
                toll = this.tol;
            end
            
            f_mind_present = @(var)(is_string(var)&&strcmp(var,'min_denominator'));
            mind_provided = cellfun(f_mind_present,keyval);
            
            if ~any(mind_provided)
                if numel(keyval)>0
                    keyval = [keyval(:);this.comparison_par(:)];
                else
                    keyval = this.comparison_par;
                end
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
            % ref_data.
            
            if isfield(this.ref_data,test_name) && isstruct(this.ref_data.(test_name))
                % Structure called test_name exists - assume new format
                S = this.ref_data.(test_name);
                if isfield(S,var_name)
                    var = S.(var_name);
                else
                    error('TestCaseWithSave:invalid_argument',...
                        'variable: %s does not exist in stored data for the test: %s',...
                        var_name,test_name);
                end
            else
                % No structure called test_name exists - assume old format
                if isfield(this.ref_data,var_name)
                    var = this.ref_data.(var_name);
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
            %   this.ref_data.(test_name).(var_name)
            
            % Get store area of named test, or create if doesnt exist
            if isfield(this.ref_data,test_name)
                S = this.ref_data.(test_name);
            else
                S = struct();
            end
            S.(var_name) = var;
            this.ref_data.(test_name) = S;
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
