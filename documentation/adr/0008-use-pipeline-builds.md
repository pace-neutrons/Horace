[<-previous](0007-use-herbert-as-library-dependency.md) | [next->](0009-use-standard-naming-for-build-artifacts.md)

# 8 - Use Jenkins scripted pipeline for builds

Date: 2019-Dec-20

## Status

Accepted

## Context

Continuous builds are needed for each target platform and operating system to maintain a set of build artifacts for the `master` branch.

Builds are also required for pull requests made on [GitHub](https://github.com/pace-neutrons).

These builds will be the same except for the commit to build (for `master` this will be the branch HEAD, for a pull request this will be a merge commit between the branch and `master`).

## Decision

Jenkins builds pipelines will be scripted (`tools/build_config/Jenkinsfile`) with minimal configuration set in the Jenkins UI.

This configuration will be:

- set required variables (e.g. build agent type, MATLAB and compiler versions)
- manage Git triggers and branches

Differences bewteen the `PR`, `Branch` and `master` builds will be split between the UI (extraction of information about pull request is required for `PR` builds) and `Jenkinsfile` scaffold (target commit to post build status).

The pipeline script will call a `build.[sh|ps1]` script with appropriate arguments to perform the build and test steps. The `Jenkinsfile` will provide a scaffold that can be applied to all build targets.

The build jobs we be organised into `Horace` and `Herbert` folders. Separate projects will be written for:

```
Horace/PR-builds
      /master-builds
      /branch-builds
Herbert/PR-builds
       /master-builds
       /branch-builds
```

Each project name will follow the pattern: `[PR-|Branch-]<target-os>-<target-matlab>`.e.g. `PR-Scientific-Linux-2018b`, `osx-2019a`, `win64-2018a`.

## Consequences

Separating the build steps from Jenkinsfile build scaffold allows the same build to be executed on the developer machine.

Creation of new build targets will require the duplication of an existing `master-` or `PR-` build with the build agent and target MATLAB updated appropriately.

The non-trivial mapping between the MATLAB version and compatible compilers is maintained by hand.