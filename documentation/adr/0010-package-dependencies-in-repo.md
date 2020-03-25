[<-previous](0009-use-standard-naming-for-build-artifacts.md) | [next->](0011-version-project-with-cmake.md)

# 10 - Package dependencies in the repository

Date: 2020-Feb-25

## Status

Accepted

## Context

There are various C++ dependencies present in Horace. For example, the version
of MPICH used should match the version used by Matlab - this avoids incompatible
shared libraries being used when executing mex functions. These libraries may
be old versions and may not be easily available for users to download.

## Decision

Dependencies will be packaged within the repo to be built against. Matlab's own
shared libraries will be built against where possible, but the static libraries
and headers required will be within the repository. Libraries will be statically
linked where possible so that the libraries do not need to be shipped to users.

## Consequences

This requires potentially large libraries to be stored within the repository,
however no large libraries are currently required.

The means by which the libraries were acquired/built will also need to be
documented or automated for reproducibility.

The licensing for the libraries will also need to be examined to ensure the
legality of including it within the repository.
