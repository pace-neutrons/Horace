add_custom_target(analyse
  COMMENT "Performing code analysis..."
  )

add_custom_target(analyse-mlint
  COMMENT "- Performing MATLAB analysis (Mlint)..."
  BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/mlint.out"
  COMMAND ${Matlab_MAIN_PROGRAM} -nodisplay -batch "\"addpath('${Herbert_ROOT}/admin');lint_json({'${CMAKE_SOURCE_DIR}/**/*.m'},'${CMAKE_CURRENT_BINARY_DIR}/mlint.json');exit\""
  WORKING_DIRECTORY
  USES_TERMINAL
  )
add_dependencies(analyse analyse-mlint)

find_program(cppcheck NAMES cppcheck)
if (cppcheck)
  add_custom_target(analyse-cppcheck
    COMMENT "- Performing C++ analysis (CppCheck)..."
    BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/cppcheck.xml"
    COMMAND cppcheck --enable=all --inconclusive --xml --xml-version=2 -I "${CMAKE_SOURCE_DIR}/_LowLevelCode/cpp" "${CMAKE_SOURCE_DIR}/_LowLevelCode/" 2> "${CMAKE_CURRENT_BINARY_DIR}/cppcheck.xml"
    WORKING_DIRECTORY
    USES_TERMINAL
    )
  add_dependencies(analyse analyse-cppcheck)
else()
  message(STATUS "cppcheck not found, cannot analyse-cppcheck")
endif()
