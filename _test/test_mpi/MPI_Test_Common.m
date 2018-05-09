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

    end
    properties(Access=private)
        framework_name 
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
                pc.parallel_framework = obj.framework_name;
                if ~strcmpi(pc.parallel_framework,obj.framework_name)
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
        
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

