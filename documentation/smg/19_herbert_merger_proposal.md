# Procedure to amalgamate the Herbert repository into Horace

### Feb 1. 2022

## Introduction

The development team recently agreed that it would be a good idea to amalgamate the
[Herbert](https://github.com/pace-neutrons/Herbert/)
and [Horace](https://github.com/pace-neutrons/Horace) repositories,
in order to avoid duplication of settings, start-up routines and CI tests.

This system management guide proposes a procedure to accomplish this amalgamation.
The requirements of this procedure are that:

* It should not impact other developments of Horace / Herbert
* It should retain the histories of both repositories
* Continuous integration builds and tests should work seamlessly across the transition.

In addition to these requirements there is a major secondary goal of reducing the
size of the repository (currently ~1.3GB for *Horace* and ~110MB for *Herbert*),
which in particular means removing or reducing the ~850MB of test files in *Horace*,
to alternative storage as noted in
[ADD09](https://github.com/pace-neutrons/Horace/blob/7c9e35b08831212ff23656832c81162261a20226/documentation/add/09_test_data_storage.md),
and then amending the repo history in order excise these files and thus reduce the repo size.
A minor secondary goal is to rename the default branch to `main` to keep in
consistency with new naming conventions.


## Plan

Since *Horace* is the larger repository, the plan is to merge *Herbert* into Horace,
using the following steps:

0. A fork `pace-neutrons/Horace_backup` is created to retain the test files in
   case they need to be reverted, as they will be deleted from history in step 9.
1. New branches `Horace/main` and `Herbert/main` are created to mirror the default `master` branches.
   The contents of *Herbert* is copied into *Horace* but not committed.
   All items under `herbert_core` will be moved to `horace_core`,
   and other folders merged into each other with conflicts resolved manually.
   Commits to ensure the two repositories do not conflict will be made to `Horace/main`
   and `Herbert/main` separately.
   In particular, these include changes needed to ensure all tests run successfully.
   Development (pull requests) on *Horace* and *Herbert* proceeds on the respective `master` branches as normal.
   Merged pull requests will be updated in the respective `main` branch by rebasing,
   in order to ensure a seamless history.
2. A Jenkins pipeline will be setup on the new amalgamated `Horace/main` branch configured
   to run tests for the combined Horace / Herbert, with the contents of `Herbert/main` copied into *Horace*.
3. Test data is reduced / removed as much as possible (but the history will not be changed so the repo size remains unchanged).
4. This step marks when testing / CI builds are judged satisfactory, and the repos are ready to be merged.
5. All pull requests in *Herbert* must be closed and rebased into `Herbert/main`.
6. `Herbert/main` is merged into `Horace/main` so that all the history of *Herbert* is transferred to *Horace*.
7. All open issues in *Herbert* are transferred to *Horace*.
8. The back-up fork `pace-neutrons/Horace_backup` is updated to the current state of the main *Horace* repo
9. The history of *Horace* is rewritten to excise the large test data files, and the changes pushed to Github.
10. The amalgamated branch `Horace/main` is set as the default branch on Github and all open pull
    requests on *Horace* are re-targeted to this rather than the defunct `Horace/master` branch.
11. Jenkins pipeline are retargeted at `Horace/main` or other *Horace* branches as needed.

Note that throughout steps 0-5 for Herbert and 0-9 for Horace, developments will proceed normally
on the `master` branches, and new changes there will be rebased into the `main` branches.
This ensures a seamless history until the amalgamation in step 6.

Steps 6-11 must be done in a very short period of time (at most a few hours) in order to minimize disruption,
and this must be done after every pull request in *Herbert* is closed.

Alternatively, if *Herbert* developers are willing to resolve conflicts themselves after step 10 is accomplished,
they can open a new pull request in *Horace* with their code changes, cherry-picking commits to retain the history.

For open *Horace* pull requests, some manual conflict resolution will probably be needed after step 10 but
this should be much less than for *Herbert* pulls - hopefully only retargeting the branch from `Horace/master` to `Horace/main`


## Prototyping Update (May 26 2022)

In order to make some progress with this issue, a bare-bones prototype was carried out.
This consists of two branches off `master`, called `main`,
one in [Herbert](https://github.com/pace-neutrons/Herbert/compare/main) and the
other in [Horace](https://github.com/pace-neutrons/Horace/compare/main).
These will be kept up to date with `master` by rebasing.

*This working prototype essentially completes step 1 of the above plan.*

When it is decided that Herbert and Horace can be merged, the following commands can
be used:

```sh
git clone https://github.com/pace-neutrons/Horace
cd Horace
git checkout main
git remote add herbert https://github.com/pace-neutrons/Herbert
git fetch herbert
git merge herbert/main --allow-unrelated-histories \
                       --strategy=ort --strategy-option=theirs \
                       -m "Merging Herbert into Horace"
./tools/build_config/build.sh --configure --cmake_flags "-DHorace_RELEASE_TYPE=Release"
./tools/build_config/build.sh --analyze
./tools/build_config/build.sh --build
./tools/build_config/build.sh --test
```

Note that the `git merge` command needs `git` version 2.33 or newer as it requires
the use of the `ort` strategy which is not present in older versions of `git`.
The `ort` strategy is the default for `git` after 2.33 and handles renamed files
better than the previous default `recursive` strategy.
The `--strategy-option=theirs` forces any conflicts to be auto-resolved in
favour of the code in **Herbert** (e.g. Herbert code where it overlaps will
overwrite Horace code).

The `merger_diffs` branches contain minimum changes
(mostly to `CMakeLists.txt` files and similar, but with some clashing folders in
`documentation` and `_test` renamed - see the linked diffs above).
This will allow the two codes to live in a single repository, and for tests to pass.

At present some tests in **Horace** fail with this error:

```
energy transfers have to be array of numeric values. It is: field_var_array
```

This is due to [recent changes in Herbert](https://github.com/pace-neutrons/Herbert/pull/441)
to support the [generic projections work](https://github.com/pace-neutrons/Horace/pull/795).
(Merging the generic projections in makes all tests pass).

After the merge, there will still be separate `herbert_core` and `horace_core` folders but
all other ancillary folders (e.g. `admin`, `_LowLevelCode`, `_test`, etc.) will be merged.
Merging `herbert_core` into `horace_core` can be left as a separate PR.
