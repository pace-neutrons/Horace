#[=======================================================================[.rst:
herbert_FindGTest
-----------------

Download and build GoogleTest and GMock. Then, export variables with which we
can link the libraries to our tests.

When adding a test executable to CMake you can link it to GoogleTest and/or
GMock using the following:

.. code-block::
    add_executable(MY_TEST_EXE ${SRC_FILES})
    target_link_libraries(MY_TEST_EXE gtest gmock)


Variables defined by the module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``gtest``
The gtest library.

``gtest_main``
The gtest_main library. This contains, on top of the ``gtest`` library, an
entry-point 'main' function from which tests can be run. Since ``gtest_main``
contains everything in ``gtest`` you should use one or the other when linking.

``gmock``
The gmock library.

``gmock_main``
The gmock_main library.

This script is based on the script given in the CMake guide on GoogleTest's
GitHub https://github.com/google/googletest/blob/master/googletest/README.md.

#]=======================================================================]
set(GTEST_DOWNLOAD_DIR "${CMAKE_BINARY_DIR}/googletest-download")
# Copy the CMakeLists file that imports the external project
configure_file(
    "${CMAKE_SOURCE_DIR}/cmake/templates/GTest-CMakeLists.txt.in"
    "${GTEST_DOWNLOAD_DIR}/CMakeLists.txt")

# Run configure on the CMakeLists file
execute_process(
    COMMAND ${CMAKE_COMMAND} -G "${CMAKE_GENERATOR}" .
    RESULT_VARIABLE RESULT
    WORKING_DIRECTORY "${GTEST_DOWNLOAD_DIR}"
)

if(RESULT)
    message(FATAL_ERROR "CMake configure step for googletest failed: ${RESULT}")
endif()

# Run the build step
execute_process(
    COMMAND ${CMAKE_COMMAND} --build .
    RESULT_VARIABLE RESULT
    WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/googletest-download")
if(RESULT)
    message(FATAL_ERROR "Build step for googletest failed: ${RESULT}")
endif()

# We don't want to install GTest libs when we run `make install`
set(INSTALL_GTEST OFF CACHE BOOL "Enable installation of googletest." FORCE)
# Prevent overriding the parent project's compiler/linker settings on Windows
if(WIN32)
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
endif()

# Add googletest directly to our build. This defines the gtest and gtest_main
# targets.
add_subdirectory("${CMAKE_BINARY_DIR}/googletest-src"
                 "${CMAKE_BINARY_DIR}/googletest-build")

# Put the GTest libraries into `External` folder for Visual Studio
foreach(_lib "gtest" "gtest_main" "gmock" "gmock_main")
    set_target_properties(${_lib} PROPERTIES
        FOLDER "External")
endforeach()

# The gtest/gtest_main targets carry header search path dependencies
# automatically when using CMake 2.8.11 or later. Otherwise we have to add them
# here ourselves.
if (CMAKE_VERSION VERSION_LESS 2.8.11)
  include_directories("${gtest_SOURCE_DIR}/include")
endif()
