classdef TestPerformance < TestCaseWithSave
    % Test suite to verify performance achieved during some time-consuming
    % operations
    %
    %
    % The performance results (in second) are stored in a xml file
    % combining results for all hosts where the tests were run
    % The format of the file is as follows:
    % -host_name1|->test_name1|->test_time(sec)
    %                         |->comment
    %                         |->completeon date
    %            |->test_name2|->test_time(sec)
    %                         |->comment
    %                         |->completeon date
    %            |->test_name3|->test_time(sec)
    %                         |->comment
    %                         |->completeon data
    % -host_name2|->test_name1|->test_time(sec)
    %                         |->comment
    %                         |->completeon date
    %            |->test_name2|->test_time(sec)
    %                         |->comment
    %                         |->completeon date
    %            |->test_name3|->test_time(sec)
    %                         |->comment
    %                         |->completeon date
    %
    % where test_name is the name, provided as input of assertPerformance
    % method
    %
    % The host_name is the variable combined from the preffix containign the
    % output of Hergbert getHostName function
    %
    % $Revision: 1524 $ ($Date: 2017-09-27 15:48:11 +0100 (Wed, 27 Sep 2017) $)
    %
    properties(Dependent)
        % current performance suite name to run.
        % Its defined as the computer name the test is running on
        % plus some additional information, identifying performance test
        % settings e.g. number of files to combine or number of workers to
        % use.
        perf_suite_name;
        % The name of the test to run or have just been running. Defined by
        % assertPerformance method.
        current_test_name
        % time to run current test which should not be substantially increase
        % on a given machine. The first time one runs the test on the
        % machine, it is ignored
        time_to_run = [];
        % performance data to compare against or store current results,
        % containing the results of all previous performance tests on
        % different pc.
        perf_data
    end
    
    
    properties(Access=protected)
        % performance test suite name to run/verify. The name is build from
        % the performance test class name and is the root name for all
        % tests to attach to
        perf_suite_name_;
        %
        % all performance data to compare against or store current results
        perf_data_ = struct();
        % The name of the test to run or have just been running. Defined by
        % assertPerformance method.
        current_test_name_ =[];
        % time to run the test which should not be substantially increase
        % on a given machine. The first time one runs the test on the
        % machine, it is ignored
        time_to_run_ = [];
        % The name of the test class, used as the name of the root node in
        % the performance test results
        root_name_
    end
    methods
        %------------------------------------------------------------------
        function tr = get.perf_suite_name(obj)
            % the name of the test suite to run. Defines the place and
            % possibly the parameters  for tests to run
            tr = obj.perf_suite_name_;
        end
        function set.perf_suite_name(obj,val)
            % the name of the test suite to run. Defines the place and
            % possibly the parameters  for tests to run
            obj.perf_suite_name_ = val;
            if ~isfield(obj.perf_data_,val)
                ts = obj.perf_data_;
                ts.(val) = '';
                obj.perf_data_ = ts;
            end
        end
        
        function tr = get.time_to_run(obj)
            % the time to run resent test case
            tr = obj.time_to_run_;
        end
        function tn = get.current_test_name(obj)
            tn = obj.current_test_name_;
        end
        function pfd = get.perf_data(obj)
            % returns the structure, containing all performance data,
            % availible for tests. Can be equivalent to loading the whole
            % perf_test_res_file in memory
            pfd = obj.perf_data_;
        end
        %------------------------------------------------------------------
        function obj = TestPerformance(varargin)
            % create test suite and load existing perfomance data.
            %
            %Usage:
            %>>tob = TestPerformance([name,[perf_test_res_file]]);
            % Possible inputs:
            % name -- the name of the test, used by test suite to identify
            %         cuttent test. The most derived child class name is used by defaul
            % perf_test_res_file
            %      -- full path and the name of the file to
            %         store performance results. TestPerformance class
            %         folder is used by default. If this place is
            %         write-protected, tmp folder is used instead
            %
            if nargin>0
                name = varargin{1};
                if nargin>1
                    file = varargin{2};
                else
                    file = TestPerformance.default_PerfTest_fname(mfilename('fullpath'));
                end
            else
                name = get_class_name_(dbstack);
                file = TestPerformance.default_PerfTest_fname(mfilename('fullpath'));
            end
            obj = obj@TestCaseWithSave('-save',name,file);
            obj.root_name_ = name;
            
            %
            tests_res_file = obj.test_results_file;
            %
            % get sutie test name. Should support overloading to generate
            % correct name for child classes
            %
            if exist(tests_res_file,'file')==2
                obj.perf_data_ = load_performance_data_(obj);
            end
            obj.perf_suite_name = obj.build_test_suite_name(name);
        end
        %
        function this_pc_perf_data = assertPerformance(obj,start_time,...
                test_method_name,comments,force_save)
            % save performance data if the previous version for current pc
            % does not exist or test performance against previously stored
            % performance data
            %
            % start_time -- time of the test run start measured by tic
            %               function
            % test_method_name -- the name of the test method to verify
            %
            % comments    -- optional string describing the test
            %
            % force_save -- if present, performance results are saved
            %                regardless of the changes in the performance
            %
            if ~exist('comments','var')
                comments = '';
            end
            if ~exist('force_save','var')
                force_save = false;
            end
            
            % get and store this test results
            run_time               = toc(start_time);
            %
            obj.current_test_name_ = test_method_name;
            obj.time_to_run_       = run_time;
            
            suite_name        = obj.perf_suite_name;
            all_perf_data     = obj.perf_data_;
            this_pc_perf_data = obj.perf_data_.(suite_name);
            
            if isfield(this_pc_perf_data,test_method_name)
                test_res = this_pc_perf_data.(test_method_name);
                old_time = test_res.time_sec;
                perf_change = 2*(old_time-run_time)/(old_time+run_time);
                if (perf_change  < -0.1 && old_time > 1) % the time increase is 10 and the interval is larger than 1 sec
                    warning('TEST_PERFORMANCE:performance_decreased',...
                        'Test: %s performance decreased by %3.2f perc. Old time: %d sec New time: %d sec',...
                        test_method_name,-100*perf_change,old_time,run_time);
                elseif perf_change > 0.1 && old_time > 1
                    fprintf('******** Test: %s performance increased by %3.2f perc. Old time: %d sec New time: %d sec\n',...
                        test_method_name,100*perf_change,old_time,run_time)
                end
            else
                perf_change = 100;
            end
            
            % store test results within the global results structure
            date_time = clock;
            this_pc_perf_data.(test_method_name) = ...
                struct('time_sec',run_time,...
                'comment',comments,...
                'completed_on',date_time);
            
            all_perf_data.(suite_name) = this_pc_perf_data;
            obj.perf_data_ = all_perf_data;
            
            % save only significant changes in performance
            if abs(perf_change) > 0.1 || force_save
                save_performance_data_(obj);
            end
            
            
            
        end
        %-------------------------------------------------------------
        function name = build_test_suite_name(obj,addinfo)
            % function used to generate test suite name. The name should
            % include name of the computer the test is run on + some additional
            % information to identify this pc performance settings,e.g.
            % number of files for gen_sqw test or number of workers to run.
            %
            % The parent version uses only computer name and
            % attaches to this name any additional information,
            % contained in addinfo string.
            % A child class should/may overload this method to provide
            % additinal information for the test suite
            %
            % The addinfo stirng should have form, allowed to use as the
            % name of a field in a structure.
            %
            hpc = hpc_config;
            framework_name = hpc.parallel_framework;
            if strcmp(framework_name,'matlab')
                fn = getComputerName();
            else
                fn = [getComputerName(),'_',framework_name];
            end
            if exist('addinfo','var')
                name = [fn,'_',addinfo];
            else
                name  = fn;
            end
            % remove all . from a computer name to include unix names.
            name   = strrep(name  ,'.','_');
            
        end
    end
    methods(Access=protected)
        function filename = check_test_results_file(obj,name)
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
            filename = check_test_performance_fname_(name);
        end
        
    end
    methods(Static)
        function test_file=default_PerfTest_fname(test_location)
            % build default performance test file name name in the specified
            % test file location.
            %
            test_file = build_default_perf_test_fname_(test_location);
        end
    end
end
