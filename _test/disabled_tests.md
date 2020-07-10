# Disabled tests

- test_herbert_on.m
  - test_herWrongEmpty (no ticket)

- test_job_dispatcher_parpool.m
  - test_job_submittion (Its not a disabled test, but a tester to debug job submission on a cluster)

  # all MPI exec test disabled; https://github.com/pace-neutrons/Herbert/issues/178
- test_job_dispatcher_mpiexec.m                 ! All disabled https://github.com/pace-neutrons/Herbert/issues/155
  - test_job_fail_restart - Windows only        ! Random hand-uo of one or another
  - test_job_with_logs_3workers - Windows Only  ! on Windows.
  
- test_exchange_CPP_MPI -- Currently disabled, https://github.com/pace-neutrons/Herbert/issues/178
  - test_JobExecutor ! Disabled as https://github.com/pace-neutrons/Herbert/issues/155  
  - test_job_executor
  - test_init_mpiexec_mpi_fw  ! Disabled as https://github.com/pace-neutrons/Herbert/issues/155
  %
