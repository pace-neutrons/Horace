classdef MPI_Test_Common < TestCase
    % The class used as the parent to test various mpi exchange classes.
    %
    % Contains all common settings, necessary to test parpool mpi
    %   Detailed explanation goes here
    
    properties
        %
        working_dir
        % if parallel toolbox is not available or parallel framework is not
        % available, test should be counted as  passed but ignored.
        % Warning is necessary.
        ignore_test = false;
        %
        old_config;
        % current name of the framework to test
        framework_name ;
        % current worker used in tests
        worker='worker_4tests'
    end
    properties(Access=private)
        current_config_folder;
        parallel_config_;
    end
    
    methods
        function obj = MPI_Test_Common(name,varargin)
            obj = obj@TestCase(name);
            
            if nargin > 1
                obj.framework_name = varargin{1};
            else
                obj.framework_name = 'parpool';
            end
            
            pc = parallel_config;
            if strcmpi(pc.parallel_framework,'none')
                obj.ignore_test = true;
                warning('MPI_Test_Common:not_available',...
                    'unit test to check parallel framework is not available as framework is not installed properly')
                return;
            end
            obj.parallel_config_ = pc;
            %pc.saveable = false;
            obj.working_dir = pc.working_directory;
            obj.old_config  = pc.get_data_to_store();
            try
                pc.parallel_framework = obj.framework_name;
                if strcmpi(pc.parallel_framework,obj.framework_name)
                    set_framework = true;
                else
                    set_framework = false;
                end
            catch ME
                if strcmp(ME.identifier,'PARALLEL_CONFIG:invalid_configuration')
                    set_framework = false;
                    warning(ME.identifier,'%s',ME.message);
                elseif strcmp(ME.identifier,'PARALLEL_CONFIG:not_available')
                    set_framework = false;
                    warning(ME.identifier,'%s',ME.message);
                else
                    rethrow(ME);
                end
            end
            %
            if ~set_framework
                obj.ignore_test = true;
                hc = herbert_config;
                if hc.log_level>0
                    warning('MPI_TEST_COMMON:not_availible',...
                        ['The framework: ', obj.framework_name, ...
                        ' can not be enabled so is not tested'])
                end
            else
                obj.ignore_test = false;
            end
            
        end
        function setUp(obj)
            if obj.ignore_test
                return;
            end
            pc = obj.parallel_config_;
            pc.saveable = false;
            pc.parallel_framework = obj.framework_name;
            pc.worker = obj.worker;
        end
        function tearDown(obj)
            if obj.ignore_test
                return;
            end
            
            set(parallel_config,obj.old_config);
            obj.parallel_config_.saveable = true;
        end
        function delete(obj)
            obj.tearDown();
        end
    end
end

