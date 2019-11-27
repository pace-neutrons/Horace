[<-previous](0003-use-cmake-for-build.md) | [next->](0005-use-gtest-in-cpp-tests.md)

# 4 - CPP tests in separate projects

Date: 2019-NOV-20

## Status

Accepted

## Context

A large number of test files will be created  during the project. These should be stored in
a consistent location across the C++ projects.

A number of options are available:

* filing alongside the source files
* in a `tests/` folder within the source tree
* in a `.Tests` project created alongside the application source

## Decision

We will create a parallel directory structure of test projects for each C++ project.

``` file listing
service\
  functionOne\
    CMakeLists.txt
    ...
  functionTwo\
    CMakeLists.txt
    ...
  tests\
    functionOne.Tests\
      CMakeLists.txt
      ...
    functionTwo.Tests\
      CMakeLists.txt
      ...
```

The test projects will include the associated function project as an explicit reference e.g.

```cmake
add_executable("functionOne.test" ${TEST_SRC_FILES} ${TEST_HDR_FILES} ${SRC_FILES} ${HDR_FILES})
target_include_directories("functionOne.test" PRIVATE "${CMAKE_SOURCE_DIR}/_LowLevelCode/cpp")
target_link_libraries("functionOne.test" gtest_main)
```

This enables the test artifacts and dependencies to be simply excluded from system components that  will be deployed. The separation will also provide a clear cognitive separation between `function` and `function.Test` and support further extension to `function.IntegrationTest`.

## Consequences

* Consistent code layout across project

* Test code simply excluded from release builds

* Additional C++ project overhead

* For C++ projects including a mex wrapper, the MATLAB mex libraries must be added explicitly, i.e.

  ```cmake
   target_include_directories("functionOne.test" PRIVATE "${CMAKE_SOURCE_DIR}/_LowLevelCode/cpp" "${Matlab_INCLUDE_DIRS}")
   target_link_libraries("functionOne.test" gtest_main "${Matlab_MEX_LIBRARY}" "${Matlab_MX_LIBRARY}" "${Matlab_UT_LIBRARY}")
  ```
