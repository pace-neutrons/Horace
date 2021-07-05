classdef gen_sqw_common_config < TestCase
    % Class-parent for gen_sqw tests, containing the logic, responsible for
    % changing these tests configuration to the tested one
    %
    properties
        % common property for number of child classes, where some tests
        % should not run due to the system not satisfies the conditions for
        % them to run and  the classes can not be tested
        skip_test = false;
        % if necessary, the config folder to store job data
        new_working_folder=''
    end
    properties(Access=protected)
        old_configuration_=[];
        
        new_mex_  = false;
        new_mpi_ = false;
        new_combine_ = 'mex_code'
        new_cluster_ = 'herbert';
        
        worker = 'worker_v2'
        % Store the name of the worker, currently used by Horace parallel
        % framework, to recover after the tests are completed.
        current_worker_cache_ = [];
    end
    
    methods
        
        function obj = gen_sqw_common_config(use_mex,use_MPI,combine_sqw_using,parallel_cluster)
            % class constructor, which defines necessary test configuration
            % options. The option can be defined by one of three numbers:
            % -1 -- ignore this option for test, leave it as in current configuration.
            %  0 -- disable this options
            %  1 -- enable this options
            % namely:
            % use_mex  -- if the test should use mex files for calculations
            % use_MPI  -- if the test should deploy parallel framework
            %
            %combine_sqw_using-- if the test should combine tmp files using
            %             mex code, matlab code or mpi code/
            %             the possible options here are:
            %             -1,'matlab','mex_code','mpi_code'
            %parallel_cluster -- which parallel framework to deploy.
            %           the possible values here are:
            %           -1, 'herbert' or 'parpool'
            obj = obj@TestCase('nop');
            obj.store_initial_config();
            hc = hor_config;
            log_level = hc.log_level;
            
            
            [~,obj.new_mex_ ] = gen_sqw_common_config.check_change...
                ('use_mex',use_mex,obj.old_configuration_.hc);
            if obj.new_mex_ % check mex can be enabled
                [~,n_errors]=check_horace_mex();
                if n_errors>0
                    use_mex = 0;
                else
                    use_mex = 1;
                end
                if ~use_mex
                    obj.skip_test = true;
                    if log_level>0
                        warning('GEN_SQW_TEST_CONFIG:not_available',...
                            ['Can not initiate mex mode: ',...
                            ' This mex mode will not be tested'])
                    end
                end
            end
            
            [~,obj.new_mpi_ ] = gen_sqw_common_config.check_change...
                ('build_sqw_in_parallel',use_MPI,obj.old_configuration_.hpc);
            
            [~,obj.new_combine_ ] = gen_sqw_common_config.check_change...
                ('combine_sqw_using',combine_sqw_using,obj.old_configuration_.hpc);
            
            [change_framework,obj.new_cluster_ ] = gen_sqw_common_config.check_change...
                ('parallel_cluster',parallel_cluster,obj.old_configuration_.parc);
            if ~change_framework
                obj.new_cluster_  =obj.old_configuration_.parc.parallel_cluster;
            end
            [jen,job_folder] = is_jenkins();
            if jen
                [~,job_folder] = fileparts(job_folder);
                obj.new_working_folder = fullfile(tmp_dir(),job_folder);
            end
            
            if ~isnumeric(parallel_cluster) % check parallel framework can be enabled
                cl = MPI_clusters_factory.instance().get_cluster(parallel_cluster);
                if isempty(cl) 
                    obj.skip_test = true;                                        
                    if log_level>0
                        warning('GEN_SQW_TEST_CONFIG:not_available',...
                          'Can not initiate framework: %s because this cluster is not available on the system. This mode will not be tested',...
                                parallel_cluster)
                    end                    
                else
                    obj.skip_test = false;                                        
                end
            end
        end
        
        function setUp(obj)
            if obj.skip_test
                return;
            end
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = obj.new_mex_;
            hpc = hpc_config;
            hpc.saveable = false;
            hpc.build_sqw_in_parallel = obj.new_mpi_;
            hpc.combine_sqw_using = obj.new_combine_;
            parc = parallel_config;
            parc.saveable = false;
            parc.parallel_cluster = obj.new_cluster_;
            if ~isempty(obj.new_working_folder)
                parc.working_directory = obj.new_working_folder;
            end
            
            obj.current_worker_cache_ = parc.worker;
            parc.worker = obj.worker;
            
        end
        %
        function tearDown(obj)
            obj.restore_initial_config();
        end
        %
        function delete(obj)
            obj.restore_initial_config();
        end
        %
        function store_initial_config(obj)
            hc = hor_config;
            hpc = hpc_config;
            parc = parallel_config;
            obj.old_configuration_ = ...
                struct('hc',hc.get_data_to_store(),...
                'hpc',hpc.get_data_to_store(),...
                'parc',parc.get_data_to_store());
        end
        %
        function restore_initial_config(obj)
            if ~isempty(obj.old_configuration_)
                hc = hor_config;
                hpc = hpc_config;
                parc = parallel_config;
                set(hc,obj.old_configuration_.hc);
                set(hpc,obj.old_configuration_.hpc);
                set(parc ,obj.old_configuration_.parc);
            end
        end
    end
    methods(Static)
        function [change,new_value] = check_change(field_name,new_value,old_config)
            % helper function to convert input constructor option into the
            % internal values, used by the class.
            old_value = old_config.(field_name);
            %new_value = old_value;
            if ischar(new_value)
                if strcmpi(old_value,new_value)
                    change = false;
                else
                    change = true;
                end
            else
                if new_value == -1
                    change = false;
                else
                    if new_value == old_value
                        change = false;
                    else
                        change = true;
                    end
                end
            end
        end
    end
end

