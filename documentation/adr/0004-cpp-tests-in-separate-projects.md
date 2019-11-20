[<-previous](0003-use-cmake-for-build.md) | next->

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

```
target_link_libraries(functionOne.Tests functionOne ...)
```

This enables the test artifacts and dependencies to be simply excluded from system components that  will be deployed. The separation will also provide a clear cognitive separation between `function` and `function.Test` and support further extension to `function.IntegrationTest`.

## Consequences

* Consistent code layout across project
* Test code simply excluded from release builds
* Additional C++ project overhead