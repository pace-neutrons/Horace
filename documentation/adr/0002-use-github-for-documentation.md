[<-previous](0001-record-architecture-decisions.md) | [next->](0003-use-cmake-for-build.md)

# 2. Use GitHub for Project Documentation

Date: 2019-Nov-06

Updated: 2021-Jan-13

## Status

Accepted

## Context

We need to store project documentation (Developer Guides, System Architecture, System Maintenance, Test Plans) somewhere that it is easy to read and update.

Documentation will directly reference Horace and Herbert projects.

The GitHub Wiki repository does not support pull requests, or the display of any content not on the the `master` branch.


## Decision

~We will store documentation in the `Horace/documentation` folder and link to this from the [GitHub Wiki](https://github.com/pace-neutrons/pace-developers/wiki) which is attached to the PACE project on GitHub.~ 

We will store documentation in the `Horace/documentation` folder which will be built regularly and deployed to the GitHub pages under the following scheme: 

The documentation will be supported and built by the Jenkins pipeline and automatically deployed on:
- nightly builds (unstable)
- deploy pipeline (stable & horace-version)

The Jenkins will also build the documentation as a zipped artefact on other pipelines (PR, Branch, etc.) to ensure that any modifications do not affect the documentation. Following the implementation of documentation tests, will also ensure that scripts contained in the documentation remain valid and functional. 

## Consequences

- Documentation will be written in markdown.
- Storing in the main source repository means changes can be tracked and reviewed through pull requests. 
- PDF versions of the documentation can be quickly and simply generated using some off-the-shelf tooling if required.
- Markdown stored at [pace-developers/wiki](https://github.com/pace-neutrons/pace-developers.wiki.git) will link to the documentation.
- Documentation will be stored as part of the Horace project [Horace/documentation](https://github.com/pace-neutrons/horace.git).
