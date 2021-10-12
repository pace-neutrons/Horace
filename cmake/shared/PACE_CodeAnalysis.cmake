#[=======================================================================[.rst:
PACE_CodeAnalysis
-----------------

Run mlint and cppcheck code analysis on Project

Variables required by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``${Herbert_ROOT}``
This is provided by the `FindHerbert` module which must be loaded first

``${PACE_MLINT_IGNORE}``
CMake list of filepaths or globs describing files to exclude from mlint parsing

``${Matlab_MAIN_PROGRAM}``
This is provided by the `herbert_FindMatlab` module which must be loaded first

Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``${cppcheck}``
Location of the CPPCheck executable

Targets defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``analyse``
Run full analysis (both cppcheck and mlint if available)

``analyse-mlint``
Run mlint analysis

``analyse-cppcheck``
Run cppcheck analysis

#]=======================================================================]


add_custom_target(analyse
  COMMENT "Performing code analysis..."
  )

# Handle CMAKE list to matlab cell array
string(JOIN "','" IGNORE_STRING ${PACE_MLINT_IGNORE})

string(CONCAT RUN_MLINT "\""
                        "addpath('${Herbert_ROOT}/admin');"
                        "lint_json({'${${PROJECT_NAME}_CORE}/**/*.m',"
                                   "'${${PROJECT_NAME}_ROOT}/admin/**/*.m',"
                                   "'${${PROJECT_NAME}_ROOT}/_test/**/*.m'},"
                                   "'${CMAKE_CURRENT_BINARY_DIR}/mlint.json',"
                                   "'exclude',{'${IGNORE_STRING}'});"
                        "exit;"
                        "\"")

add_custom_target(analyse-mlint
  COMMENT "- Performing MATLAB analysis (Mlint)..."
  BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/mlint.out"
  COMMAND ${Matlab_MAIN_PROGRAM} -nodisplay -batch "${RUN_MLINT}"
  WORKING_DIRECTORY
  USES_TERMINAL
  )
add_dependencies(analyse analyse-mlint)

find_program(cppcheck NAMES cppcheck)
if (cppcheck)
  add_custom_target(analyse-cppcheck
    COMMENT "- Performing C++ analysis (CppCheck)..."
    BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/cppcheck.xml"
    COMMAND cppcheck --enable=all --inconclusive --xml --xml-version=2
                     -I "${CMAKE_SOURCE_DIR}/_LowLevelCode/cpp" "${CMAKE_SOURCE_DIR}/_LowLevelCode/"
                     2> "${CMAKE_CURRENT_BINARY_DIR}/cppcheck.xml"
    WORKING_DIRECTORY
    USES_TERMINAL
    )
  add_dependencies(analyse analyse-cppcheck)
else()
  message(STATUS "cppcheck not found, cannot analyse-cppcheck")
endif()
