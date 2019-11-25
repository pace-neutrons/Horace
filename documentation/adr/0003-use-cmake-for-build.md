[<-previous](0002-record-architecture-decisions.md) | [next->](0004-cpp-tests-in-separate-projects.md)

# 3. Use CMake for build tool

Date: 2019-11-06

## Status

Accepted

## Context

The project will need to be built for multiple platforms Windows (VStudio), MacOS, Linux (gcc/Make) and include compilation of Matlab and C++ (with Matlab API wrapper).

## Decision

We will use [CMake](https://cmake.org/) to provide a platform agnostic build definition that can be configured for each target platform. 

## Consequences

- Exactly one definition of the build will exist.
- The generated makefiles and vcproj files will need to be bundled into the releases to enable users to rebuild locally without CMake.
