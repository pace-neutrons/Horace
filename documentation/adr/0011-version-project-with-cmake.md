[<-previous](0010-package-dependencies-in-repo.md) | [next->](0012-use-network-storage-for-large-datafiles.md)

# 11 - Version project using CMake

Date: 2020-Mar-25

## Status

Accepted

## Context

Every instance of the project should carry an up-to-date version number. This
version number should be accessible from within the Matlab and C++ code.

## Decision

The version number will be defined in a top-level VERSION file. This file
should contain a version number of format \<major\>.\<minor\>.\<patch\> and
nothing else, including whitespace.

CMake will read the VERSION file and formate template Matlab and C++ files.
These templates will be copied into the Matlab/C++ source tree by CMake at
configure time.

If CMake is building a developer version (i.e. CMake variable
`Horace_RELEASE_TYPE` is not equal to `RELEASE`), CMake will append a Git SHA
to the end of the version number. The Git SHA will be excluded from builds
created via the release pipeline; builds generated locally by developers and in
pull request/nightly Jenkins jobs will include the SHA.

If CMake has not been run and has not generated the Matlab file containing the
version, Matlab will read the VERSION file and append `.dev` to the version.
This will signify this is an un-built developer version.

## Consequences

- The version number for the project will be defined in one place.
- The version number will be accessible from within Matlab and C++.
- The version number will be correct for every build.
- The version returned by the Matlab version will not be updated until CMake is
  run. This means local developer copies of the repo will have outdated
  version SHAs if CMake has not been run.
