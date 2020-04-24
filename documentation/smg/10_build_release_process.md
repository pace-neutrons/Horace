# Build/Release pipeline

Build and test pipelines have been created in ANVIL for the Horace and Herbert source.

All users should be using a build that has been built, tested and packaged using the build script.

### Master

The `master` branch should always be 'releasable' with all tests passing. Builds are run on all target platforms to create a `.zip`/`.tar.gz` release packages each night.

- The Herbert `master` branch is built and a zip release build artifact with MATLAB-release and platform-specific binary is created.

- The Horace `master` branch is built and zip release build artifact with MATLAB-release and platform-specific binary created, which includes the last successful Herbert `master` build.

The Horace build artifact is a single deployable unit to a specific MATLAB/OS platform. This is equivalent to the artifact created by the legacy MATLAB create release process.

### Features

Feature development and bug fixes should be performed on branches and reviewed using a GitHub Pull Request (PR).

When a pull request is opened or updated the merged code of the PR branch and `master` is built and tested.

1. Feature developed on a branch taken from the `master`
2. All tests likely to be affected by changes in Herbert and Horace must be run on developers machine
3. Create Herbert PR (if required) for merge into `master` branch
4. Create Horace PR (if required) - if a Herbert PR has been created too the Horace PR must not be merged until the Herbert PR has been merged
5. If the build / test against of the PR against the Release branch succeeds on all platforms the PR can be merge.

### Hot fixing

Patch releases should be tested and built through the same build pipeline as the initial production releases.

<img src="./images/10_git_hotfix_branches.png">

1. User reports issue
2. Bug report issue created in GitHub/Issues documenting how to reproduce
3. Fix developed on a branch (`xxx_branch`) taken from the *release* tag (`Rm_n_o`)
4. All tests likely to be affected by changes in Herbert and Horace must be run on developers machine
5. PR created for merge into Release branch (`rel_m_n_o`) *and* `master` branch. If this is the first release patch, the branch will need to be created
6. If the build and test of the PR to the Release branch succeeds on all platforms, that build artifact can be released to the target platform as version `m.n.o+1`

If the hotfix is being done out-of-hours the PR can be merged by the developer WITHOUT review provided all tests pass, but the branch should not be deleted and should be reviewed as the earliest opportunity.

The same caveats apply about the Horace build dependencies on Herbert.

Advantages:

- build tools are not required on the production hardware
- all builds are created using the same build tools
- users are using a known, traceable, validated release

Disadvantages:

- slower; have to wait for full build and test pipeline to execute

### Releases

The Jenkins build artifacts are are not accessible outside of STFC. End users will be directed to GitHub to access packaged releases.

A 'deploy' pipeline will be created ([Horace #73](https://github.com/pace-neutrons/Horace/issues/73)). 

This will:

- tag the `master` branch with the release number (`Rm_n_o`)
- copy the built artifact to the GitHub

The release tag will be an anchor for any subsequently needed release branch and patch branches.

The version number is stored in a text file (`VERSION`) in the root of the Herbert and Horace source. This will follow [semantic versioning](https://semver.org/) and is used in the build process to set the version number in the MATLAB and compiled C++ components.

### Facility Deployment

Users participating in ISIS experiments use expensive neutron facility and need to be able to see and analyse their data as quickly as possible, ideally in the process of experiment and immediately after that. In addition to standard Horace scripts users sometimes write their own scripts, which places high demand on the software reliability. Sometimes, their custom scripts use standard software in the operational modes, which are difficult to predict. Often these script identify issues, which have not been anticipated during development so users need urgent fixing or modifications to the software. Sometimes, the issues can be caused by specific user's data, so can be easily reproduced only using these data. The changes fixing the user issue should occur immediately, as users should not lose a day or even an hour waiting until the whole build pipeline completes, produces all possible artefacts and get installed on the facility computers.  

Quick modifications to the software with only partial testing carries the risks of breaking the other parts of the software. Despite that, in reality, single crystal experiments on different machines rarely happen simultaneously. The combined probability of error in modified code and the situation when this error immediately and severely affects another high priority user can be considered low. If this happens, the possibility to revert changes as rapidly as they were introduced, is also very important. 

Because of the specific demands, the process of deploying the software on the ISIS facility differs from the  normal build-release process. 

Namely:

When a release is produced and placed to the github, the master branch is tagged with the release number. 
The release tagged version is checked out in the common software area of the ISIS computing facility provided to users. The low level build artefacts i.e. C++ libraries are copied into appropriate places of this area from the Jenkins node, testing release on this system. 

If any errors are identified during user cycle, a bugfixing branch is created from the actual release. The changes, fixing user issue are committed to the github as soon as they are introduced. The changes become the contents of the bugfixing PR, which is reviewed, tested against all remaining code base and operating systems and eventually becomes the part of **master** like any other code changes. 

Such workflow allows rapid response to the requests of the users, who is carrying out their experiments, with only minor temporary decrease in the code reliability.

The changes to low level performance code are considered high risk changes, so they are not introduced using this process. They are also not considered the critical changes as the code expected to run correctly without low level C++ code, may be with decreased performance. 

