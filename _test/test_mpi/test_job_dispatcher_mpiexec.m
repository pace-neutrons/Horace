classdef test_job_dispatcher_mpiexec < job_dispatcher_common_tests

    properties
    end
    methods
        %
        function this=test_job_dispatcher_mpiexec(name)
            if ~exist('name','var')
                name = 'test_job_dispatcher_mpiexec';
            end
            this = this@job_dispatcher_common_tests(name,'mpiexec_mpi');
            this.print_running_tests = true;
        end

        function test_ClusterMPI_get_mpiexec_executable_exists(~)
            mpiexec_path = ClusterMPI.get_mpiexec();
            assertTrue(isfile(mpiexec_path));
        end

        function test_job_fail_restart(obj, varargin)
            test_job_fail_restart@job_dispatcher_common_tests(obj, varargin{:})
        end

        function test_job_with_logs_3workers(obj, varargin)
            test_job_with_logs_3workers@job_dispatcher_common_tests(obj, varargin{:})
        end

        function test_job_with_logs_2workers(obj,varargin)
            test_job_with_logs_2workers@job_dispatcher_common_tests(obj, varargin{:})
        end

        function test_job_with_logs_worker(obj, varargin)
            test_job_with_logs_worker@job_dispatcher_common_tests(obj, varargin{:})
        end

    end
end
