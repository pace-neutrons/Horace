classdef gen_sqw_common_config < TestCase
    % Class-parent for gen_sqw tests, containing the logic, responsible for
    % changing these tests configuration to the tested one
    %
    properties
        % common property for number of child classes, where some tests
        % should not run due to the system not satisfies the conditions for
        % them to run and  the classes can not be tested
        skip_test = false;
        
    end
    properties(Access=protected)
        old_configuration_=[];
        
        change_mex_=false;
        set_mex_  = false;
        
        change_mpi_=false;
        set_mpi_ = false;
        
        change_combine_=false;
        set_combine_ = false;
        
        change_framework_ = false;
        framework_to_set_ = 'herbert';
    end
    
    methods
        
        function obj = gen_sqw_common_config(use_mex,use_MPI,use_mex4combine,parallel_framework)
            % class constructor, which defines necessary test configuration
            % options. The option can be defined by one of three numbers:
            % -1 -- ignore this option for test, leave it as in current configuration.
            %  0 -- disable this options
            %  1 -- enable this options
            % namely:
            % use_mex  -- if the test should use mex files for calculations
            % use_MPI  -- if the test should deploy parallel framework
            %use_mex4combine -- if the test should combine tmp files using
            %             mex code
            %parallel_framework -- which parallel framework to deploy.
            %           Unlike all other options the possible values here are:
            %           -1, 'herbert' or 'parpool'
            obj = obj@TestCase('nop');
            obj.store_initial_config();
            hc = hor_config;
            log_level = hc.log_level;
            
            
            [obj.change_mex_,obj.set_mex_ ] = gen_sqw_common_config.check_change...
                ('use_mex',use_mex,obj.old_configuration_.hc);
            if obj.change_mex_ && obj.set_mex_
                [~,n_errors]=check_horace_mex();
                if n_errors>0
                    use_mex = 1;
                else
                    use_mex = 0;
                end
                if ~use_mex
                    obj.skip_test = true;
                    if log_level>0
                        warning('GEN_SQW_TEST_CONFIG:not_available',...
                            ['Can not initiate mex mode: '
                            ' This mode will not be tested'])
                    end
                end
            end
            
            [obj.change_mpi_,obj.set_mpi_ ] = gen_sqw_common_config.check_change...
                ('accum_in_separate_process',use_MPI,obj.old_configuration_.hpc);
            [obj.change_combine_,obj.set_combine_ ] = gen_sqw_common_config.check_change...
                ('use_mex_for_combine',use_mex4combine,obj.old_configuration_.hpc);
            
            if isnumeric(parallel_framework)
                obj.change_framework_  = false;
            elseif ischar(parallel_framework)
                cur_fmw = obj.old_configuration_.parc.parallel_framework;
                if strcmp(cur_fmw,parallel_framework)
                    obj.change_framework_ = false;
                else
                    obj.change_framework_ = true;
                    parc = parallel_config;
                    parc.parallel_framework = parallel_framework;
                    if ~strcmpi(parc.parallel_framework,parallel_framework)
                        obj.skip_test = true;
                        obj.change_framework_ = false;
                        if log_level>0
                            warning('GEN_SQW_TEST_CONFIG:not_available',...
                                ['Can not initiate framework: ',parallel_framework, ...
                                ' This mode will not be tested'])
                        end
                    else
                        obj.skip_test = false;
                    end
                end
            end
        end
        function setUp(obj)
            if obj.change_mex_
                hc = hor_config;
                hc.use_mex = obj.set_mex_;
            end
            if obj.change_mpi_
                hpc = hpc_config;
                hpc.accum_in_separate_process = obj.set_mpi_;
            end
            if obj.change_combine_
                hpc = hpc_config;
                hpc.use_mex_for_combine = obj.set_mpi_;
            end
            if obj.change_framework_
                parc = parallel_config;
                parc.parallel_framework = obj.framework_to_set_;
            end
            
        end
        function tearDown(obj)
            if obj.change_mex_
                hc = hor_config;
                hc.use_mex = ~obj.set_mex_;
            end
            if obj.change_mpi_
                hpc = hpc_config;
                hpc.accum_in_separate_process = ~obj.set_mpi_;
            end
            if obj.change_combine_
                hpc = hpc_config;
                hpc.use_mex_for_combine = ~obj.set_combine_;
            end
            if obj.change_framework_
                parc = parallel_config;
                parc.parallel_framework = obj.old_configuration_.parc.parallel_framework;
            end
            
        end
        function delete(obj)
            obj.restore_initial_config();
        end
        
        
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
        function [change,new_value] = check_change(field_name,to_use,old_config)
            % helper function to convert input constructor option into the
            % internal values, used by the class.
            old_value = old_config.(field_name);
            new_value = old_value;
            switch(to_use)
                case(-1) % ignore
                    change = false;
                case(0) % not use
                    if old_value == 1
                        change = true;
                        new_value = 0;
                    else
                        change = false;
                    end
                case(1) % use
                    if old_value == 1
                        change = false;
                    else
                        new_value = 1;
                        change = true;
                    end
                otherwise
                    error('GEN_SQW_TESTS_CONFIG:invalid_argument',...
                        'the possible values to set field %s can be [-1,0,1]',...
                        field_name);
            end
        end
    end
end

