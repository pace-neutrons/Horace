# Build/Release pipeline

Build and test pipelines have been created in ANVIL for the Horace and Herbert source.

All users should be using a build that has been built, tested and packaged using the build script.

### Master

The `master` branch should always be 'releasable' with all tests passing. Builds are run on all target platforms to created a `.zip`/`.tar.gz` release packages each night.

- The Herbert `master` branch is built and a zip release build artifact with MATLAB-release and platform-specific binary is created.

- The Horace `master` branch is built and zip release build artifact with MATLAB-release and platform-specific binary created, which includes the last successful Herbert `master` build.

The Horace build artifact is a single deployable unit to a specific MATLAB/OS platform. This is equivalent to the artifact created by the legacy MATLAB create release process.

These build artifacts are stored in Jenkins and, as such, are not accessible outside of STFC. 

A 'deploy' pipeline will be created ([Horace #73](https://github.com/pace-neutrons/Horace/issues/73)) that will tag the GitHub source with the release number and copy the built artifact to the GitHub 'releases' from where external end-users are expected to access releases.


### Features

Feature development and bug fixes should be performed on branches and reviewed using a GitHub Pull Request (PR).

When a pull request is opened or updated the code is built and tested of the merge of the PR branch and `master`.

1. Feature developed on a branch taken from the `master`
2. All tests likely to be affected by changes in Herbert and Horace must be run on developers machine
3. Create Herbert PR (if required) for merge into `master` branch
4. Create Horace PR (if required) - if a Herbert PR has been created too the Horace PR must not be merged until the Herbert PR has been merged
5. If the build / test against of the PR against the Release branch succeeds on all platforms the PR can be merge.

### Hot fixing:

Patch releases should be tested and built through the same build pipeline as the initial production releases.

1. User reports issue
2. Bug report issue created in GitHub/Issues documenting how to reproduce
3. Fix developed on a branch taken from the *release* tag (`REL_m_n_o`)
4. All tests likely to be affected by changes in Herbert and Horace must be run on developers machine
5. PR created for merge into Release branch (`release_m_n_o`) *and* `master` branch
6. If the build / test against of the PR against the Release branch succeeds on all platforms, that build artifact can be released to the target platform as version `m.n.o+1`

If the hotfix is being done out-of-hours the PR can be merged by the developer WITHOUT review, but the branch should not be deleted and should be reviewed as the earliest opportunity.

The same caveats apply about the Horace build dependencies on Herbert.

Advantages:

- build tools are not required on the production hardware
- all builds are created using the same build tools
- users are using a known, traceable, validated release

Disadvantages:

- slower; have to wait for full build and test pipeline to execute