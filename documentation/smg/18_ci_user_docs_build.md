# Automatic building of user documentation

## Summary

This system maintenance guide describes a change in the continuous integration workflow
for building and publishing user documentation created by Sphinx, described in [SMG#15](15_documentation.md).

* Documentation will henceforth be built using Github-Actions instead of Anvil/Jenkins.
* Changes to `master` will cause the documentation to be built in a published in [unstable](https://pace-neutrons.github.io/Horace/unstable/).
* Publishing a [release](https://github.com/pace-neutrons/Horace/releases/new) on Github will cause
  documentation to be build and published to the corresponding `vX.Y.Z` folder, and linked 
  (using `http-refresh` redirection) in the [stable](https://pace-neutrons.github.io/Horace/stable/) folder.

## Previous situation

Previously, the documentation was built and pushed (published) in Jenkins.
However, the [build script](https://github.com/pace-neutrons/Horace/blob/7bc3e41d5bec4090f8ee1ebae97259cd6629823e/tools/build_config/build.sh#L96) always copies the built documentation to the `unstable` folder regardless of whether
the build was triggered by a release or nightly build.
The previous stable (v3.6.0) documentation was published manually.

## New workflow

The user documentation publishing scripts and triggers will be removed from the `build.sh` / `build.ps1` and `Jenkinsfile`.
Instead there will be two github-action scripts,
one for [unstable](https://github.com/pace-neutrons/Horace/blob/master/.github/workflows/push_docs_unstable.yml)
and one for [stable](https://github.com/pace-neutrons/Horace/blob/master/.github/workflows/push_docs_stable.yml).

The `unstable` script will build the documentation and publish it in the `unstable` folder.
This will run on every push to `master` (e.g. everytime a PR is merged and `master` is updated),
and can also be triggered manually
(by clicking `Run workflow` on [this page](https://github.com/pace-neutrons/Horace/actions/workflows/push_docs_unstable.yml))
by any member of the `pace-neutrons` organisation.

The `stable` script will run when a release is published on Github.
It will create a new folder for the documentation, named after that release and link this folder to the `stable` folder.
