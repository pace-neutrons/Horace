classdef MPI_Test_Common < TestCase
    % The class used as the parent to test various mpi exchange classes.
    %
    % Contains all common settings, necessary to test various MPI clusters
    % and their common operations.
    %
    %
    properties
        %
        working_dir
        % if parallel toolbox is not available or parallel framework is not
        % available, test should be counted as  passed but ignored.
        % Warning is necessary.
        ignore_test = false;
        ignore_cause = '';
        % current name of the framework to test
        cluster_name;
        % current worker used in tests
        worker='worker_4tests'
    end
    properties(Access=private)
        old_parallel_config_;
        parallel_config_restore_ = '';
    end

    methods
        function obj = MPI_Test_Common(name,varargin)
            obj = obj@TestCase(name);
            persistent old_parallel_config;
            ni = MPI_Test_Common.num_instances();
            MPI_Test_Common.num_instances(ni+1);


            if nargin > 1
                obj.cluster_name = varargin{1};
            else
                obj.cluster_name = 'parpool';
            end

            [pc, opc] = set_local_parallel_config();
            if isempty(old_parallel_config) || ni == 1
                old_parallel_config = opc;
            else
                opc = old_parallel_config ;
            end
            if is_idaaas && ~isempty(which('worker_4tests_idaaas'))
                warning(' Setting parallel worker to special value: %s',...
                    which('worker_4tests_idaaas'));
                pc.worker = 'worker_4tests_idaaas';
                obj.worker = 'worker_4tests_idaaas';
            end

            obj.old_parallel_config_ = opc;
            obj.parallel_config_restore_ = onCleanup(@()set(parallel_config,opc));


            if strcmpi(pc.parallel_cluster,'none')
                obj.ignore_test = true;
                obj.ignore_cause = 'Unit test to check parallel framework is not available as framework is not installed properly';
                return;
            end
            %pc.saveable = false;
            obj.working_dir = pc.working_directory;
            try
                pc.parallel_cluster = obj.cluster_name;
                if strcmpi(pc.parallel_cluster,obj.cluster_name)
                    set_framework = true;
                else
                    set_framework = false;
                end
            catch ME
                if strcmp(ME.identifier,'HERBERT:parallel_config:invalid_argument')
                    set_framework = false;
                    warning(ME.identifier,'%s',ME.message);
                elseif strcmp(ME.identifier,'HERBERT:parallel_config:not_available')
                    set_framework = false;
                    warning(ME.identifier,'%s',ME.message);
                else
                    rethrow(ME);
                end
            end
            %
            if ~set_framework
                obj.ignore_test = true;
                obj.ignore_cause = ['The framework: ', obj.cluster_name, ' can not be enabled so is not tested'];
            else
                obj.ignore_test = false;
            end

        end
        %
        function setUp(obj)
            if obj.ignore_test
                return;
            end
            pc = parallel_config;
            pc.parallel_cluster = obj.cluster_name;
            pc.worker = obj.worker;
        end
        %
        function tearDown(obj)
            if obj.ignore_test
                return;
            end
            set(parallel_config,obj.old_parallel_config_);
        end
        function delete(obj)
            ni = MPI_Test_Common.num_instances();
            ni = ni-1;
            MPI_Test_Common.num_instances(ni);
            obj.tearDown();
        end
    end
    methods(Static)
        function ni = num_instances(set_value)
            persistent num_instances;
            if exist('set_value', 'var')
                num_instances = set_value;
            else
                if isempty(num_instances)
                    num_instances = 1;
                end
            end
            ni = num_instances;
        end

    end
end
