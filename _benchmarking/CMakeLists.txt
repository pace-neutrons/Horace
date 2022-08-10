add_custom_target(gen_benchmark_data
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "addpath('${CMAKE_CURRENT_SOURCE_DIR}', '${LOCAL_INIT_DIR}'); for i=[5,6,7,8,9]; gen_fake_sqw_data(i); end"
  BYPRODUCTS
  ${CMAKE_CURRENT_SOURCE_DIR}/common_data/NumData5.sqw
  ${CMAKE_CURRENT_SOURCE_DIR}/common_data/NumData6.sqw
  ${CMAKE_CURRENT_SOURCE_DIR}/common_data/NumData7.sqw
  ${CMAKE_CURRENT_SOURCE_DIR}/common_data/NumData8.sqw
  ${CMAKE_CURRENT_SOURCE_DIR}/common_data/NumData9.sqw
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Building benchmark data"
  VERBATIM
  USES_TERMINAL
  )

add_custom_target(benchmark_all
  COMMAND ${Matlab_MAIN_PROGRAM} -batch "addpath('${LOCAL_INIT_DIR}'); horace_on(); benchmark_horace('-verbose')"
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Running benchmarks"
  DEPENDS gen_benchmark_data
  DEPENDS gen_benchmark_data
  VERBATIM
  USES_TERMINAL
  )
