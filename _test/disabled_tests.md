# Disabled tests

- test_herbert_on.m
    - test_herWrongEmpty (no ticket)

- MPI_test
   # disabled on Jenkins:
   - test_job_dispatcher_herbert:test_job_with_3workers
   - test_job_dispatcher_parpool:test_job_with_3workers
   - test_job_dispatcher_mpiexec:test_job_with_3workers
   
   - test_job_dispatcher_herbert:test_job_fail_restart
   - test_job_dispatcher_parpool:test_job_fail_restart
   - test_job_dispatcher_mpiexec:test_job_fail_restart
    https://github.com/pace-neutrons/Herbert/issues/92
    
  # disabled on Windows:
   - test_job_dispatcher_mpiexec:test_job_with_3workers  
     hangs up when runs in sequence of tests, passes if tested alone (ticket to do)


- test_ParpoolMPI_Framework.m
   - test_labprobe_nonmpi (no ticket)

    
- test_job_dispatcher_parpool.m
  - test_job_submittion (no ticket)
