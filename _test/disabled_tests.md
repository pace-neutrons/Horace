# Disabled tests

- test_herbert_on.m
    - test_herWrongEmpty (no ticket)

- MPI_test
   - test_job_with_3workers https://github.com/pace-neutrons/Herbert/issues/92  
   # disabled on unix for test_job_dispatcher_parpool
   # disabled on windows for test_job_dispatcher_mpiexec

- test_ParpoolMPI_Framework.m
   - test_labprobe_nonmpi (no ticket)

    
- test_job_dispatcher_parpool.m
  - test_job_submittion (no ticket)
