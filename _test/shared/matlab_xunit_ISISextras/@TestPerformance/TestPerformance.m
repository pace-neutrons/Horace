classdef TestPerformance < TestCaseWithSave
    % Test suite to verify performance achieved during some time-consuming
    % operations
    %
    %
    % The performance results (in second) are stored in a xml file
    % combining results for all hosts where the tests were run
    % The format of the file is as follows:
    % -host_name1_perfClassName...
    %             ->test_name1|->test_time(sec)
    %                         |->comment
    %                         |->completeon date
    %            |->test_name2|->test_time(sec)
    %                         |->comment
    %                         |->completeon date
    %            |->test_name3|->test_time(sec)
    %                         |->comment
    %                         |->completeon data
    % -host_name2_perfClassName...
    %             ->test_name1|->test_time(sec)
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
    % The host_name is the variable combined from the prefix containing the
    % output of Herbert getHostName function
    %
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
        time_to_run;
        % performance data to compare against or store current results,
        % containing the results of all previous performance tests on
        % different pc.
        perf_data
        % list of the tests, which are available to run
        tests_available
        % list of the performance test results (the structures
        % host_nameXXX_perfClassName with the data)
        known_perf_data_names
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
        %
        
        % time to run the test which should not be substantially increase
        % on a given machine. The first time one runs the test on the
        % machine, it is ignored
        time_to_run_ = [];
        % The name of the test class, used as the name of the root node in
        % the performance test results
        root_name_
        % list of the tests, which are available to run. Define within the
        % constructor for the particular performance tests, which tests are
        % available
        tests_available_ = {};
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
        function [x_axis,res_sum,res_split] = get_filtered_res(obj,dataset_template,x_axis_template,foi)
            % extract all datasets, corresponding to the dataset template
            % and obtain the data change as function of the variable,
            % defined as x_axis_template
            % x_axis_template -- the format string, used to parse the field
            %                    name,e.g. to parse string
            %                    'gen_sqw_nwk0_comb_mex_code_MODE1', a
            %                    format string
            %                    'gen_sqw_nwk%d_comb_mex_code_MODE1' used
            %                    to extract number of workers
            % foi -- number of the field of interest, i.e. if you
            %        parse string "gen_sqw_slurm_nwk2_comb_mex_code_MODE1" using
            %        format "gen_sqw_%s_nwk%d_comb_%s_MODE1", the foi = 2 to
            %       retrieve the number of workers
            %
            % Returns:
            % x_axis   -- the arrau of the values, the datasets depednd on
            %
            % res_sum  -- nres x 2 array containing average time to
            %             exectute test as function of the input parameters
            %
            % res_split -- nres x nDataset array containing the time to
            %              test for each dataset selected
            res = obj.perf_data;
            fn = fieldnames(res);
            ds_selected = contains(fn,dataset_template);
            n_datasets = sum(ds_selected);
            if n_datasets ==0
                x_axis  = [];
                res_sum = [];
                res_split=[];
                warning('No datasets containing name: "%s" found within the results',dataset_template)
                return
            end
            ds = fn(ds_selected);
            for i=1:n_datasets
                data = res.(ds{i});
                x_ax = extract_x_axis_(data,x_axis_template,foi);
                if i == 1
                    x_axis = x_ax;
                else
                    x_axis = union(x_ax,x_axis);
                end
            end
            res_split = NaN(numel(x_axis),numel(ds));
            for i=1:n_datasets
                data = res.(ds{i});
                res_split(:,i) = extract_data_(data,x_axis,x_axis_template,foi);
            end
            if n_datasets == 1
                res_sum = [res_split,zeros(numel(x_axis),1)];
            else
                res_sum = obj.calc_averages(res_split);
            end
            x_axis = double(x_axis');
        end
        %
        function serr = calc_averages(obj,res_split)
            % calculates averages and min/max deviations from
            % the given sequence ignoring NaN-s
            % data provide average and minimal and maximal values
            n_points = size(res_split,1);
            serr = zeros(n_points ,3);
            for i=1:n_points
                valid = ~isnan(res_split(i,:));
                data = res_split(i,valid);
                serr(i,1) = sum(data)/numel(data);
                serr(i,2)  = min(data);
                serr(i,3)  = max(data);
            end
        end
        %
        function tr = get.time_to_run(obj)
            % the time to run resent test case
            tr = obj.time_to_run_;
        end
        function tn = get.current_test_name(obj)
            tn = obj.current_test_name_;
        end
        function tm = get.known_perf_data_names(obj)
            pfd = obj.perf_data_;
            fnames = fieldnames(pfd);
            valid = cellfun(@(fn)(~isempty(pfd.(fn))),fnames,'UniformOutput',true);
            tm  = fnames(valid);
            
        end
        %
        function pfd = get.perf_data(obj)
            % returns the structure, containing all performance data,
            % available for tests. Can be equivalent to loading the whole
            % perf_test_res_file in memory
            pfd = obj.perf_data_;
            fn = fieldnames(pfd);
            for i=1:numel(fn)
                if isempty(pfd.(fn{i}))
                    pfd = rmfield(pfd,fn{i});
                end
            end
        end
        %------------------------------------------------------------------
        function obj = TestPerformance(varargin)
            % create test suite and load existing performance data.
            %
            %Usage:
            %>>tob = TestPerformance([name,[perf_test_res_file]]);
            % Possible inputs:
            % name -- the name of the test, used by test suite to identify
            %         current test. The most derived child class name is used by default
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
            obj = obj@TestCaseWithSave('-save',file);
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
        function perf = known_performance(obj,perf_test_name,varargin)
            % method return the known performance structure for given test suite name
            % (the bunch of tests, tried on the particular machine) if
            % such performance is known, or empty string if the performance
            % has not been measured or stored
            %
            % Inputs:
            % pert_test_name -- the name of the test to check results for
            % Optional:
            % suite_name     -- the name of the machine to check the
            %                   results for
            % Returns:
            % per            -- structure, describing performance results
            %                   if such result exist or empty array if they
            %                   are not.
            %
            if nargin <2
                error('HERBERT:TestPerformance:invalid_argument',...
                    'This function request perfromance test name as input');
            end
            if nargin > 2
                suite_name = varargin{1};
            else
                suite_name        = obj.perf_suite_name;
            end
            if isfield(obj.perf_data_,suite_name)
                this_pc_perf_data = obj.perf_data_.(suite_name);
                if isfield(this_pc_perf_data,perf_test_name)
                    perf = this_pc_perf_data.(perf_test_name);
                else
                    perf = [];
                end
            else
                perf = [];
            end
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
            % Optional:
            %
            % comments    -- string describing the test, to be stored in
            %                xml for clarity
            %
            % force_save -- performance results are saved
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
        %
        function  save_performance(obj)
            % save performance results into a performance results file
            save_performance_data_(obj);
        end
        %
        function save_to_csv(obj,varargin)
            % save performance data into csv file for further analysis.
            %
            % Usage:
            % pt.save_to_csv([filename],['-short']);
            %
            %where the form without the arguments saves the performance data
            %into default csv file
            %
            % filename -- the name of the csv file to save performance data
            % '-short' -- the form saves performance data in the short form
            %             i.e. only the test name and the execution time
            %             are exported.
            [ok,mess,short,argi] = parse_char_options(varargin,{'-short'});
            if ~ok
                error('TEST_PERFORMANCE:invalid_arguments',mess);
            end
            if isempty(argi) % build default csv file name
                [tdir,fn]= fileparts(obj.test_results_file);
                filename = fullfile(tdir,[fn,'.csv']);
            else
                [tdir,fn]= fileparts(argi{1});
                if isempty(tdir)
                    tdir= fileparts(obj.test_results_file);
                end
                filename = fullfile(tdir,[fn,'.csv']);
            end
            export_perf_to_csv_(obj.perf_data,filename,short);
        end
        %
        function tav = get.tests_available(obj)
            tav = obj.tests_available_;
        end
    end
    methods(Access=protected)
        function filename = check_test_results_file(~,name)
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
            % not exist and the class folder is writeable, sets the default
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
        %
        function test_name = build_test_suite_name(addinfo)
            % function used to generate test suite name. The name should
            % include name of the computer the test is run on + some additional
            % information to identify this pc performance settings,e.g.
            % number of files for gen_sqw test or number of workers to run.
            %
            % The parent version uses only computer name and
            % attaches to this name any additional information,
            % contained in addinfo string.
            % A child class should/may overload this method to provide
            % additional information for the test suite
            %
            % The addinfo string should have form, allowed to use as the
            % name of a field in a structure.
            %
            hpc = parallel_config;
            cluster_name = hpc.parallel_cluster;
            comp_name = getComputerName();
            p_pos = strfind(comp_name,'.');
            if ~isempty(p_pos)
                comp_name = comp_name(1:p_pos(1)-1);
            end
            if strcmp(cluster_name,'herbert')
                test_name = comp_name;
            else
                test_name = [comp_name,'_',cluster_name];
            end
            test_name = regexprep(test_name,'[/\\]','_');
            if exist('addinfo','var')
                test_name = [test_name,'_',addinfo];
            end
            % remove all . from a computer name to include unix names.
            %name   = strrep(name  ,'.','_');
            
        end
    end
end
