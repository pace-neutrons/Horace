# Adding and Running C++ Unit Tests

## Writing unit tests

Horace's C++ unit tests are written using the [GoogleTest framework](https://github.com/google/googletest).
Commands to create build targets for your tests should be written in CMake.

All C++ tests should be contained within the `<Horace_Root>/_LowLevelCode/cpp/test`
directory. For unit tests, the directory structure within the `test` directory
should mirror the structure within `<Horace_Root>/_LowLevelCode/cpp`, but
folders should have `.test` appended to their names. Source files containing
tests should have the filename suffix `.test.cpp`. For example:

```
cpp/
|
+-- my_module/
    +-- src_file_1.cpp
    +-- src_file_1.h
    +-- src_file_2.cpp
    +-- src_file_2.h
+-- my_second_module/
+-- test/
    |
    +-- my_module.tests/
        +-- src_file_1.test.cpp
        +-- src_file_2.test.cpp
    +-- my_second_module.tests/

```

If you are using any data files in your tests, the paths to the files should
be written relative to the environment variable `HORACE_ROOT`. This will mean
the tests can be run from anywhere as long as `HORACE_ROOT` points to the
top-level Horace directory.

## Adding a test in CMake

A function `horace_add_unit_test` is provided to make adding tests easier.
Suppose you are testing code within the `my_module` directory. You want to add
tests for `my_module`, and the test required libraries `GMock` and `OpenMP`.
The `CMakeLists.txt` file, within the `test/my_module.tests`directory, should
look something like the following:

```cmake
set(
    TEST_SRC_FILES
    "src_file_1.test.cpp"
    "src_file_2.test.cpp"
)
set(
    SRC_FILES
    "${CXX_SOURCE_DIR}/my_module/src_file_1.cpp"
    "${CXX_SOURCE_DIR}/my_module/src_file_2.cpp"
)

set(
    HDR_FILES
    "${CXX_SOURCE_DIR}/my_module/src_file_1.h"
    "${CXX_SOURCE_DIR}/my_module/src_file_2.h"
)

horace_add_unit_test(
    NAME "my_module.test"
    SOURCES "${TEST_SRC_FILES}" "${SRC_FILES}" "${HDR_FILES}"
    LIBS OpenMP::OpenMP_CXX gmock
    MEX_TEST
)
```

This will create a target to build an executable called `my_module.test.exe`
within the directory `<Horace_Build_Root>/tests/bin/<Debug/Release>`. The test
will automatically be linked to `gtest_main` and added to CTest. The `MEX_TEST`
flag should be used if the code requires the use of any of Matlab's mex
functions (i.e. `<mex.h>` has been included), this will link the test to the
required libraries.

## Running tests

To run tests you can execute the command `ctest` in the `<Horace_Build_Root>`
directory. To only run certain tests you can pass the `-R` flag to filter tests
using a regex.

The test executables can also be run directly, with a couple of caveats:

1) On Windows, if the test uses any mex libraries, then it must be able to
locate some Matlab DLLs; the path to these needs to be on your system path. The
DLLs are located at `<Matlab_Root>/bin/win64` for a 64-bit build (when running
the tests with CTest, this is automatically added to your path for the duration
of the tests).

2) Since all data file paths are written relative to the `HORACE_ROOT`
environment variable, this variable should be defined. If the variable is not
defined, your current working directory will need to be the top-level Horace
directory.
