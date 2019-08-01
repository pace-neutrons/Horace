classdef MPI_Test_Common < TestCase
    % The class used as the parent to test various mpi exchange classes.
    %
    % Contains all common settings, necessary to test parpool mpi
    %   Detailed explanation goes here
    
    properties
        %
        working_dir
        % if parallel toolbox is not availible, test should be ignored
        ignore_test;
        %
        old_config;
        % if default current framework is not a parpool framework,
        % one needs to change the setup
        change_setup;
        % current name of the framework to test
        framework_name ;
    end
    properties(Access=private)
        current_config_folder;
    end
    
    methods
        function obj = MPI_Test_Common(name,varargin)
            obj = obj@TestCase(name);
            
            pc = parallel_config;
            if nargin > 1
                obj.framework_name = varargin{1};
            else
                obj.framework_name = 'parpool';
            end
            
            obj.working_dir = pc.working_directory;
            
            if strcmp(pc.parallel_framework,obj.framework_name)
                obj.change_setup = false;
            else
                obj.old_config = pc.get_data_to_store;
                obj.change_setup = true;
                try
                    pc.parallel_framework = obj.framework_name;
                    set_framework = true;
                catch ME
                    if strcmp(ME.identifier,'PARALLEL_CONFIG:unsupported_configuration')
                        set_framework = false;
                    elseif strcmp(ME.identifier,'PARALLEL_CONFIG:toolbox_licensing')
                        set_framework = false;
                        warning(ME.identifier,'%s',ME.message);
                    else
                        rethrow(ME);
                    end
                end
                if ~set_framework
                    obj.ignore_test = true;
                    obj.change_setup = false;
                    hc = herbert_config;
                    if hc.log_level>0
                        warning('MPI_TEST_COMMON:not_availible',...
                            [obj.framework_name, ...
                            ' mpi can not be enabled so not tested'])
                    end
                else
                    obj.ignore_test = false;
                end
            end
        end
        function setUp(obj)
            if obj.change_setup
                pc = parallel_config;
                pc.parallel_framework = obj.framework_name;
            end
        end
        function teadDown(obj)
            if obj.change_setup
                set(parallel_config,obj.old_config);
            end
        end
    end
end

