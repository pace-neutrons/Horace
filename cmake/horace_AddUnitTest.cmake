set(TESTS_BIN_DIR "${CMAKE_BINARY_DIR}/tests/bin")

#[=======================================================================[.rst:
horace_add_unit_test
--------------------

Add a C++ unit test that links to GoogleTest.

Arguments
^^^^^^^^^

``NAME``
The name to give the test executable, e.g. `combine_sqw.test`.

``SOURCES``
The source files required to compile the test executable.

``LIBRARIES`` (optional)
The libraries to link the test to.

``MEX_TEST`` (optional, flag)
Including this flag will link the test executable to the Matlab mex libraries.

Example
^^^^^^^

horace_add_unit_test(
    NAME "mytest.test"
    SOURCES "${MY_SRC_FILES}" "${MY_HDR_FILES}"
    LIBRARIES "${MY_LIB1}" "${MY_LIB2}"
    MEX_TEST
)

#]=======================================================================]
function(horace_add_unit_test)

    # Parse the arguments
    set(prefix "TEST")
    set(noValues "MEX_TEST")
    set(singleValues "NAME")
    set(multiValues "SOURCES" "LIBRARIES")
    cmake_parse_arguments(
        "${prefix}"
        "${noValues}"
        "${singleValues}"
        "${multiValues}"
        ${ARGN}
    )
    # Check we have the required arguments
    if("${TEST_NAME}" STREQUAL "")
        message(FATAL_ERROR
            "No NAME argument given to function 'horace_add_unit_test'. Please\
            specify a name for the test.")
    endif()
    if("${TEST_SOURCES}" STREQUAL "")
        message(FATAL_ERROR "No SOURCES argument given to function \
        'horace_add_unit_test'. Please specify at least one source file for \
        the test.")
    endif()

    # Create the test executable
    add_executable("${TEST_NAME}" "${TEST_SOURCES}")
    target_include_directories("${TEST_NAME}" PRIVATE "${CXX_SOURCE_DIR}")
    target_link_libraries("${TEST_NAME}" gtest_main "${TEST_LIBRARIES}")
    set_target_properties("${TEST_NAME}" PROPERTIES
        FOLDER "Tests"
        RUNTIME_OUTPUT_DIRECTORY "${TESTS_BIN_DIR}"
    )
    # If MEX_TEST flag was passed to function, link to Matlab libraries
    if("${TEST_MEX_TEST}")
        target_link_libraries("${TEST_NAME}"
            "${Matlab_MEX_LIBRARY}"
            "${Matlab_MX_LIBRARY}"
        )
        target_include_directories(
            "${TEST_NAME}" PRIVATE "${Matlab_INCLUDE_DIRS}")
    endif()

    # Add the test to CTest
    add_test(
        NAME "${TESTS_BIN_DIR}/${TEST_NAME}"
        COMMAND "${TEST_NAME}"
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    )

endfunction()
