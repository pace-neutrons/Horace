#[=======================================================================[.rst:
pace_add_cpp_unit_test
--------------------

Add a C++ unit test that links to GoogleTest.

Before this function is defined, the variables `CXX_SOURCE_DIR` and
`TESTS_BIN_DIR` should be defined.

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
function(pace_add_cpp_unit_test)

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
        target_link_libraries("${TEST_NAME}" "${Matlab_LIBRARIES}")
        target_include_directories(
            "${TEST_NAME}" PRIVATE "${Matlab_INCLUDE_DIRS}")
    endif()

    # Prefix test name with cpp. to give easy regex for running only C++ tests
    set(_full_test_name "cpp.${TEST_NAME}")

    # Add the test to CTest
    add_test(
        NAME "${_full_test_name}"
        COMMAND "${TESTS_BIN_DIR}/${TEST_NAME}"
        WORKING_DIRECTORY "${${PROJECT_NAME}_ROOT}"
    )
    # Add Matlab dll directory to the CTest path
    if(WIN32 AND "${TEST_MEX_TEST}")
        set_tests_properties("${_full_test_name}" PROPERTIES
            ENVIRONMENT "PATH=${Matlab_DLL_DIR}"
        )
        # Set Visual Studio debugger environment variables
        # Adding the Matlab DLL directory stops errors because of missing DLLs
        # and adding ${PROJECT_NAME}_ROOT variable helps tests find data files.
        string(TOUPPER "${PROJECT_NAME}_ROOT" _proj_root_upper)
        set_target_properties("${TEST_NAME}"
            PROPERTIES
                VS_DEBUGGER_ENVIRONMENT
                    "PATH=${Matlab_DLL_DIR};%PATH%\n${_proj_root_upper}=${${PROJECT_NAME}_ROOT}"
        )
    endif()

endfunction()
