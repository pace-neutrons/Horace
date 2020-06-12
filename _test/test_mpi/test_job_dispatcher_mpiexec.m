classdef test_job_dispatcher_mpiexec < job_dispatcher_common_tests

    properties
    end
    methods
        %
        function this=test_job_dispatcher_mpiexec(name)
            if ~exist('name','var')
                name = 'test_job_dispatcher_herbert';
            end
            this = this@job_dispatcher_common_tests(name,'mpiexec_mpi');
            this.print_running_tests = true;
        end

        function test_ClusterMPI_get_mpiexec_executable_exists(~)
            mpiexec_path = ClusterMPI.get_mpiexec();
            assertTrue(isfile(mpiexec_path));
        end

        function test_job_fail_restart(obj, varargin)
            % DISABLED on Windows -- random hang-up of one or another
            if ispc
                warning('test_job_fail_restart disabled on Windows')
                return;
            end
            test_job_fail_restart@job_dispatcher_common_tests(obj, varargin{:})
        end

        function test_job_with_logs_3workers(obj, varargin)
            % DISABLED on Windows -- random hang-up of one or another
            if ispc && is_jenkins
                warning('test_job_with_logs_3workers disabled on jenkins')
                return;
            end
            test_job_with_logs_3workers@job_dispatcher_common_tests(obj, varargin{:})
        end

        function test_job_with_logs_2workers(obj,varargin)
            if is_jenkins
                warning('test_job_with_logs_2workers disabled on Jenkins')
                return;
            end
            test_job_with_logs_2workers@job_dispatcher_common_tests(obj, varargin{:})
        end

        function test_job_with_logs_worker(obj, varargin)
            test_job_with_logs_worker@job_dispatcher_common_tests(obj, varargin{:})
        end

    end
end
