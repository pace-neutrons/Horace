classdef gen_sqw_accumulate_sqw_MPI_common_test < gen_sqw_accumulate_sqw_common_test
    % Series of tests of gen_sqw and associated functions run on pool of
    % workers, provided by Matlab parallel computing toolbox.
    %
    %
    % Optionally writes results to output file to compare with previously
    % saved sample test results
    %---------------------------------------------------------------------
    % Usage:
    %
    %1) Normal usage:
    % Run all unit tests and compare their results with previously saved
    % results stored in test_gen_sqw_accumulate_sqw_output.mat file
    % located in the same folder as this function:
    %
    %>>runtests test_gen_sqw_accumulate_sqw_parpool
    %---------------------------------------------------------------------
    %2) Run particular test case from the suite:
    %
    %>>tc = test_gen_sqw_accumulate_sqw_parpool();
    %>>tc.test_[particular_test_name] e.g.:
    %>>tc.test_accumulate_sqw14();
    %or
    %>>tc.test_gen_sqw();
    %---------------------------------------------------------------------
    %3) Generate test file to store test results to compare with them later
    %   (it stores test results into tmp folder.)
    %
    %>>tc=test_gen_sqw_accumulate_sqw_sep_session('save');
    %>>tc.save():
    properties
        change_framework = false;
        change_hpc = false;
        old_framework;
        old_parallel_config=[];
        
        %
        working_dir;
    end
    methods
        function obj=gen_sqw_accumulate_sqw_MPI_common_test(test_name,framework_name)
            % constructor
            
            obj = obj@gen_sqw_accumulate_sqw_common_test(test_name,framework_name);
            obj.working_dir = tempdir;
            
            pc = parallel_config;
            
            if strcmp(pc.parallel_framework,framework_name)
                obj.change_framework = false;
            else
                obj.old_framework = pc.parallel_framework;
                obj.old_parallel_config = pc.get_data_to_store;
                obj.change_framework = true;
                pc.parallel_framework = framework_name;
                if ~strcmpi(pc.parallel_framework,framework_name)
                    obj.skip_test = true;
                    obj.change_framework = false;
                    hc = herbert_config;
                    if hc.log_level>0
                        warning('MPI_TEST_COMMON:not_availible',...
                            ['Can not initiate framework: ',framework_name, ...
                            ' This mode will not be tested'])
                    end
                else
                    obj.skip_test = false;
                end
            end
            
            hpc_con = hpc_config;
            if ~hpc_con.accum_in_separate_process
                obj.change_hpc =true;
            end
        end
        function setUp(obj)
            if obj.change_hpc
                hpc_con = hpc_config;
                hpc_con.accum_in_separate_process = true;
            end
            
        end
        function tearDown(obj)
            if obj.change_hpc
                hpc_con = hpc_config;
                hpc_con.accum_in_separate_process = false;
            end
        end
        function delete(obj)
            if ~isempty(obj.old_parallel_config)
                pc = parallel_config;
                set(pc,obj.old_parallel_config);
            end
        end
    end
    
end
