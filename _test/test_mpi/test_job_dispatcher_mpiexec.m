classdef test_job_dispatcher_mpiexec < job_dispatcher_common_tests

    methods

        function this=test_job_dispatcher_mpiexec(name)
            if ~exist('name', 'var')
                name = 'test_job_dispatcher_mpiexec';
            end
            this = this@job_dispatcher_common_tests(name,'mpiexec_mpi');
            this.print_running_tests = true;
        end

        function test_ClusterMPI_get_mpiexec_executable_exists(~)
            mpiexec_path = ClusterMPI.get_mpiexec();
            assertTrue(isfile(mpiexec_path));
        end

   end

end
