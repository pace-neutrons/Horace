classdef test_job_dispatcher_slurm < job_dispatcher_common_tests

    methods

        function this=test_job_dispatcher_slurm(name)
            if ~exist('name', 'var')
                name = 'test_job_dispatcher_slurm';
            end
            this = this@job_dispatcher_common_tests(name,'slurm_mpi');
            this.print_running_tests = true;
        end

   end

end
