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
        worker='worker_4testsV4'
    end

    properties(Access=private)
        stored_config_
        old_parallel_config_;
        parallel_config_restore_ = '';
    end

    methods

        function obj = MPI_Test_Common(name,varargin)
            obj = obj@TestCase(name);

            if nargin > 1
                obj.cluster_name = varargin{1};
            else
                obj.cluster_name = 'parpool';
            end

            try
                cleanUpObj = set_temporary_config_options('parallel_config','parallel_cluster',obj.cluster_name);
                pc = parallel_config;
                set_framework = strcmpi(pc.parallel_cluster,obj.cluster_name);
            catch ME
                switch ME.identifier
                    case {'HERBERT:parallel_config:invalid_argument', 'HERBERT:parallel_config:not_available'}
                        set_framework = false;
                        warning(ME.identifier,'%s',ME.message);
                    otherwise
                        rethrow(ME);
                end
            end
            obj.ignore_test = ~set_framework;
            if obj.ignore_test
                obj.ignore_cause = ['The framework: ', obj.cluster_name, ' can not be enabled so is not tested'];
                return;
            end
            if strcmpi(pc.parallel_cluster,'none')
                obj.ignore_test = true;
                obj.ignore_cause = 'Unit test to check parallel framework is not available as framework is not installed properly';
                return;
            end

            if is_idaaas && ~isempty(which('worker_4testsV4_idaaas'))
                warning(' Setting parallel worker to special value: %s',...
                    which('worker_4testsV4_idaaas'));
                obj.worker ='worker_4testsV4_idaaas';
            end

            if is_jenkins
                warning(' Setting parallel worker to special value: %s',...
                    which('worker_v4'));
                obj.worker = 'worker_v4';
            end

            ws = which(obj.worker);
            if isempty(ws)
                warning(' Setting parallel worker to special value: %s',...
                    which('worker_v4'));

                obj.worker = 'worker_v4';
                ws = which(obj.worker);
                if isempty(ws)
                    error('HERBERT:MPI_Test_Common:runtime_error',...
                        'Can not find a worker to test MPI')
                end
            end
        end
        %
        function setUp(obj)
            if obj.ignore_test
                return;
            end
            obj.stored_config_ = config_store.instance().get_all_configs();
            pc = set_local_parallel_config();

            pc.parallel_cluster = obj.cluster_name;
            pc.worker = obj.worker;
            % used somewhere in tests
            obj.working_dir = pc.working_directory;
        end
        %
        function tearDown(obj)
            if obj.ignore_test
                return;
            end
            config_store.instance().set_all_configs(obj.stored_config_);
        end
    end
end
