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
    % $Revision$ ($Date$)
    %
    properties
        % list of the reference (restored) datasets one compares against
        % or the datasets one intends to save.
        ref_data=struct();
        % default accuracy of the save_or_test_variables method
        tol = 1.e-8;
        % where to store/restore test results. By default (if this value is empty),
        % the results are restored from the test folder
        % and stored to tmp folder.
        results_path ='';
        % the name of the file to store/restore sample test result
        results_filename='results_to_compare_with.mat';
        %
        % true if we want to save test results and true if save them as example
        % to test against it later.
        want_to_save_output=false;
        
        % default parameters for equal_to_tol function used by
        % save_or_test_variables method. See equal_to_tol function for
        % other methods.
        comparison_par={'min_denominator', 0.01};
        %--- Auxiliary properties.
        % list of files to delete after test case is completed.
        filelist_toclear={};
        % list of path to remove from Matlab data search path at test class
        % destruction.
        path_toclear={};
        % the string printed in the case of errors in
        % save_or_test_variables intended to provide additional information
        % about the error (usually set in front of save_or_test_variables)
        errmessage_prefix = ''
        % HACK -- see the sort_pixels method description.
        %
        % if enabled, pixel in workspaces are first sorted before
        % comparing two workspaces together.
        sort_pixels = false;
    end
    
    methods
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
        function rm_files(this,varargin)
            for i=1:numel(varargin)
                if exist(varargin{i},'file')
                    delete(varargin{i});
                end
            end
        end
        %------------------------------------------------------------------
        function delete(this)
            warn=warning('off','all');
            rm_files(this,this.filelist_toclear{:});
            
            for i=1:numel(this.path_toclear)
                rmpath(this.path_toclear{i});
            end
            warning(warn);
        end
        %------------------------------------------------------------------
        function this=add_to_files_cleanList(this,varargin)
            this.filelist_toclear=add_data_to_list(this.filelist_toclear,varargin{:});
        end
        %
        function this=add_to_path_cleanList(this,varargin)
            this.path_toclear= add_data_to_list(this.path_toclear,varargin{:});
        end
        %------------------------------------------------------------------
        function this=save_or_test_variables(this,varargin)
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
            % earlier variables or set them up for saving these variables later.
            for i=1:numel(ws_list)
                if not(this.want_to_save_output)
                    %
                    ref_dataset = this.get_ref_dataset_(ws_names{i},test_name);
                    [ok,mess]=equal_to_tol(ws_list{i}, ref_dataset,toll,keyval{:});
                    assertTrue(ok,[this.errmessage_prefix,': [',inputname(i+1),'] :',mess])
                else
                    this = this.set_ref_dataset_(ws_list{i},ws_names{i},test_name);
                end
            end
        end
        %------------------------------------------------------------------
        function save(this)
            % Method runs test methods but not tests the data provided as input for
            % save_or_test_variables functions but saves these data to the file
            % to compare against these data later.
            %
            % the file to save is defined by class property value: results_filename
            % and the datasets itself are the datasets used as inputs to
            % save_or_test_variables method.
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
            % (may happen if the child has been initiated without -save
            % parameter)
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
        
    end
    %
    methods(Static)
        
    end
    %
    methods(Access=private)
        %
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
        %
        function ref_ds = get_ref_dataset_(this,ref_name,test_name)
            % retrieve reference dataset  corresponding to the source_ds workspace
            %
            % throws, if correspondent dataset can not be found
            %
            %Inputs:
            % ref_name -- the name of dataset to retrieve
            % test_name -- the name of the test this dataset belongs to
            %
            % if dataset is not find in the structure with the test_name
            % it is looked for on top level structure (old Horace
            % TestCaseWithSave.save_or_test_variables function format.)
            
            % check old format where workspaces are stored according to their names
            if isfield(this.ref_data,ref_name) % old format:
                ref_ds = this.ref_data.(ref_name);
            else % check the new format where dataset stored according to tests
                if isfield(this.ref_data,test_name)
                    ws_struct = this.ref_data.is_name;
                    if isfield(ws_struct,ref_name)
                        ref_ds = ws_struct.(ref_name);
                    else
                        error('TestCaseWithSave:invalid_argument',...
                            'reference workspace: %s does not exist in reference structure: %s',...
                            ref_name,test_name);
                    end
                else
                    error('TestCaseWithSave:invalid_argument',...
                        'reference workspace: %s for test with name: %s does not exist',...
                        ref_name,test_name);
                end
            end
        end
        %
        function this = set_ref_dataset_(this,ref_ds,ref_ds_name,test_name)
            % store reference dataset in datasets memory for saving it on
            % hdd later
            %
            % Inputs:
            % ref_ds        -- dataset to store
            % ref_ds_name   -- the name it should be stored with
            % test_name     -- the name of the test, this dataset belongs
            %                  to.
            if isfield(this.ref_data,test_name) % the structure for the ref_ds already exist
                ref_str = this.ref_data.(test_name);
                ref_str.(ref_ds_name) = ref_ds;
                this.ref_data.(test_name) = ref_str;
            else
                % create the structure with the name of the test to
                % validate
                ref_dat = struct();
                ref_dat.(ref_ds_name) = ref_ds;
                this.ref_data.(test_name) = ref_dat;
            end
        end
    end
end

