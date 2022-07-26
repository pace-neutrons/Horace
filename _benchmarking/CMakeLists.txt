add_custom_target(benchmark_all
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "addpath('${LOCAL_INIT_DIR}'); horace_on(); benchmark_horace('-verbose')"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Running benchmarks"
  VERBATIM
  USES_TERMINAL
  )
