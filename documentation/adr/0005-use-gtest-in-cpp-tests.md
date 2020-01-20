[<-previous](0004-cpp-tests-in-separate-projects.md) | [next->](0006-use-jenkins-for-ci.md)

# 5 - Use GTest in CPP tests

Date: 2019-Nov-27

## Status

Accepted

## Context

C++ tests are required for the project. For writing these, a testing framework
should be used.

Below is a shortlist of C++ testing frameworks:

* [GoogleTest](https://github.com/google/googletest)
* [Catch2](https://github.com/catchorg/Catch2)
* [CXXTest](https://cxxtest.com/)

## Decision

We will use GoogleTest as the framework for our C++ tests.

GoogleTest was chosen because it is:

* in active development
* used by other teams within ISIS (IBEX, Mantid use the mocking framework)
* required by [Google Benchmark](https://github.com/google/benchmark), which
could become useful in the future.
* equipped with a mocking framework

CXXTest has not had any development for several years and Catch2, whilst being
easy to set-up (it's header only), is not used elsewhere within ISIS.

## Consequences

Developers will need a local - built - copy of GoogleTest in order to write
C++ tests. This is achieved via CMake, which will download GoogleTest at
configure time.

Tests will need to be linked to GoogleTest in CMake. For example:

```cmake
add_executable("myFunction.test" "${TEST_SRC_FILES}" "${SRC_FILES}")
target_link_libraries("myFunction.test" gtest_main)
```

If the mocking library is required you must link to `gmock` as well as
`gtest_main`.