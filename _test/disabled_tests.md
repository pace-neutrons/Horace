# Disabled tests

- test_herbert_on.m
  - test_herWrongEmpty (no ticket)

- test_job_dispatcher_parpool.m
  - test_job_submittion (Its not a disabled test, but a tester to debug job submission on a cluster)

- test_mpi
    - test_job_dispatcher_mpiexec  fails on windows Jenkins with Matlab 2019b (https://github.com/pace-neutrons/Herbert/issues/329)
        :test_job_with_logs_2workers
        :test_job_with_logs_3workers
        :test_job_fail_restart
  
