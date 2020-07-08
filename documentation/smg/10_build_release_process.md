# Build/Release pipeline

Build and test pipelines have been created in ANVIL for the Horace and Herbert source.

All users should be using a build that has been built, tested and packaged using the build script.

### Master

The `master` branch should always be 'releasable' with all tests passing. Builds are run on all target platforms to create `.zip`/`.tar.gz` release packages each night.

- The Herbert `master` branch is built and a zip release build artifact with MATLAB-release and platform-specific binary is created.

- The Horace `master` branch is built and a zip release build artifact with MATLAB-release and platform-specific binary is created, which includes the last successful Herbert `master` build.

The Horace build artifact is a single deployable unit to a specific MATLAB/OS platform. This is equivalent to the artifact created by the legacy MATLAB create release process.

### Features

Feature development and bug fixes should be performed on branches and reviewed using a GitHub Pull Request (PR).

When a pull request is opened or updated the merged code of the PR branch and `master` is built and tested.

1. Feature developed on a branch taken from the `master`
2. All tests likely to be affected by changes in Herbert and Horace must be run on developers machine
3. Create Herbert PR (if required) for merge into `master` branch
4. Create Horace PR (if required) - if a Herbert PR has been created too the Horace PR must not be merged until the Herbert PR has been merged
5. If the build / test of the PR against the Release branch succeeds on all platforms, and the code has been reviewed, the PR can be merged.

### Releases

The Jenkins build artifacts are are not accessible outside of STFC. End users will be directed to GitHub to access packaged releases.

A 'deploy' pipeline will be created ([Horace #73](https://github.com/pace-neutrons/Horace/issues/73)).

This will:

- tag the `master` branch with the release number (`Rm_n_o`)
- copy the built artifact to GitHub

The release tag will be an anchor for any subsequently needed release branch and patch branches.

The version number is stored in a text file (`VERSION`) in the root of the Herbert and Horace source. This will follow [semantic versioning](https://semver.org/) and is used in the build process to set the version number in the MATLAB and compiled C++ components.

### Deployment on ISIS computational services machines
To provide rapid response to user request, bug-fixes and all advantages of constant deployment process, the release code is rapidly available to users who uses ISIS computational resources to process the results of their experiments. The services, providing these resources are currently iDaaaS and ISISCOMPUTE services. These services provide to users pool of virtual (iDaaaS) or real (ISISCOMPUTE) Linux machines, connected to the common parallel file system.

By agreement, each machine of the pool has `/usr/locam/mprogs` area containing symbolic links to the repository with Herbert and Horace code, available to users. Currently users have read access to Horace/Herbert code through symbolic links `/usr/local/mprogs/Horace` referring to `/internal_changable_location/Horace_git/horace_core` location and  `/usr/local/mprogs/Herbert` referring to `/internal_changable_location/Herbert_git/herbert_core` location, where `/internal_changable_location/Horace_git\Herbert_git` are the places where the relese version of the repository is checked out. Currently `/internal_changable_location` on ISISCOMPUTE referes to `/home/isis_direct_soft` and is mounted in `/media/` area of iDaaaS VM-s. In addition to that, `/usr/local/mprogs/` contains reference to `Users` folder, where Horace/Herbert and parallel worker initialization scripts are located. (see [Installation with Horace not initialized by default](http://horace.isis.rl.ac.uk/Download_and_setup#Installation_with_Horace_not_initialized_by_default_on_starting_Matlab) for the contents of these scripts)
*Startup.m* script auto-generated on all service machines intended for the users of inelastic experiments, enables Herbert/Horace code when Matlab starts.

The members of **mslice** group on ISISCOMPUTE and the same group of peoples, assigned by iDaaaS support team has write access to these code areas. New people are added to this list on request from iDaaaS support team. (Relies on good communication between iDaaaS team and the PACE team.) Alex Buts or FBU IT support team can currently add users to **mslice** group on ISISCOMPUTE.

As soon as release branch is tagged and created in the repository, manual build/release process is preformed in the private area of an ISISCOMPUTE or iDaaaS machine to obtain release artifacts for the computational service. This will be automated in a future, as [iDaaaS testing pipeline](https://github.com/pace-neutrons/Horace/issues/271) is implemented. The releaser then manually checks out the release branch into `Herbert_git/Horace_git` areas above and copies the release artifacts into appropriate places of the code tree.

The similar operation is performed in `Herbert_bugfix/Horace_bugfix` areas described below.

The script which automates these operations and performs internal releases as one-click operation will be developed in the nearest future.


### Patch releases

The experience shows that the main reasons for the bugs, identified by users is small changes in user configuration, specific for a user, and correct but unexpected users actions. This is why, the bugfix process in ISIS normally starts from user sharing screen with the member of the support team and demonstration of the issue to the support.

As soon as the issue is confirmed and is obvious that the bug fixing needs changes in code base, the member of the support team should switch user to the code tree, where the changes would not affect other users.
To achieve this, two additional symbolic links are available in  `/usr/local/mprigs` area, namely  `/usr/local/mprogs/Horace_bugfix` and `/usr/local/mprogs/Herbert_bugfix`, which point to separate clones of git repository. At release, they are pointing to the same location as regular Horace/Herbert branches.


To switch user to these branches, one issues `herbert_on(/usr/local/mprogs/Herbert_bugfix/herbert_core)` and `horace_on(/usr/local/mprogs/Horace_bugfix/horace_core)` command.

If parallel execution is necessary, the support needs to do similar changes in worker_4tests script available in the **User** folder above. herbert_on/horace_on commands within this script should be modifued to point to the bugfix code. The parallel config worker field should then assigned `worker_4tests` value. The default value of this field is worker_v2 where default Horace/Herbert code base is initialized.


Patch releases will be made to release branches to resolve specific bugs identified. These should be tested and built through the same build pipeline as the initial production releases.

<img src="./images/10_git_hotfix_branches.png">

1. User reports issue
2. Bug report issue created in GitHub/Issues documenting how to reproduce, and include any custom scripts or data that triggered the issue
3. Fix developed on a branch (`xxx_branch`) taken from the *release* tag (`Rm_n_o`)
4. All tests likely to be affected by changes in Herbert and Horace must be run on developers machine
5. PR created for merge into Release branch (`rel_m_n`) *and* `master` branch. If this is the first release patch, the branch will need to be created
6. If the build and test of the PR to the Release branch succeeds on all platforms, that build artifact can be released to the target platform as version `m.n.o+1`

If the hotfix is being done out-of-hours the PR can be merged by the developer WITHOUT review provided all tests pass, but the branch should not be deleted and should be reviewed at the earliest opportunity.

On any Horace release branch, the associated version of Herbert (`Rm_n_x`) will remain unchanged except for patches.

The same caveats apply about the Horace build dependencies on Herbert.

Advantages:

- build tools are not required on the production hardware
- all builds are created using the same build tools
- users are using a known, traceable, validated release

Disadvantages:

- slower; have to wait for full build and test pipeline to execute



### Hot-fix Releases

If a particular fix is required quickly on a target system, the full build and test process can be bypassed so that facility users do not lose critical machine time.

Quick modifications to the software, with only partial testing, carry the risks of breaking other parts of the software, so this is an exceptional use-case. Non-time critical issues should be resolved through the standard Patch Release process.

"Hot-fix" pipelines will be created in ANVIL ([Horace #241](https://github.com/pace-neutrons/Horace/issues/241) that only build and package Herbert and Horace and do not run the tests.

This will complete is around 5 minutes as it is the test execution step of the standard PR pipeline that take in excess of an hour to run.

1. User reports issue
2. Bug report issue created in GitHub/Issues documenting how to reproduce, and include any custom scripts or data that triggered the issue
3. Fix developed on a branch (`xxx_branch`) taken from the *release* tag (`Rm_n_o`)
4. New tests demonstrating the issue and its resolution are developed. Tests identified as being likely to be affected by the code changes run on developer's machine
5. Run the branch through the "hot-fix" build pipeline on Jenkins that *just* executes the build and package steps
6. The build artifact can be released to the specific target platform as version `m.n.o.<sha>`
7. Open PR to merge the hot-fix branch into the `master` and `rel_m_n` branches, as per the standard Patch Release process
8. When the build and test of the PR to the Release branch succeeds on all platforms, that build artifact can be released to all platforms as version `m.n.o+1`



Advantages::

- users will run a tested and built version of Horace on all platforms most of the time
- changes fixing an issue can be made rapidly so users will lose a minimum amount of time while running experiments
- hot-fixed releases will have a version number including the the commit-SHA, so the build will be identifiable and traceable
- no requirement to maintain a separate production branch. The only "maintained" branches are the release branches and master
- patches will be rapidly deployed and well-defined, reproducible build
- packaged hot-fix release will be identical to a standard release so can be deployed using the same processes

Disadvantages:

- not fully tested code released to part of the production system, alleviated by the fact that affected user experienced issue anyway.

