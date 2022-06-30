# Disabled tests

- test_herbert_on.m
  - test_herWrongEmpty (no ticket)

- test_job_dispatcher_parpool.m
  - test_job_submittion (Its not a disabled test, but a tester to debug job submission on a cluster)

- test_mpi % Disabled on Matlab 2019b windows Jenkins only (https://github.com/pace-neutrons/Herbert/issues/365)
    - test_job_dispatcher_mpiexec  fails on windows Jenkins with Matlab 2019b
        :test_job_with_logs_2workers
        :test_job_with_logs_3workers
        :test_job_fail_restart
  
- test_ParpoolMPI_Framework 
    - test_finish_tasks_reduce_messages Disabled on Windows Jenkins Matlab 2018b only due to launch instability (rare 1/10)
    
- test_multifit_legacy  -- fully disabled due to deprecating the code and the changes according to ticket #392

- test_serializers
  -test_serialise -- number of tests are disabled according to ticket #394
  -test_serialize_size --  number of tests are disabled according to ticket #394
  -test_serialize    -- problem with arrays #394
  -test_cpp_deserialise -- all disabled (#394)