[<-previous](0006-use-jenkins-for-ci.md) | [next->](0008-use-pipeline-builds.md)

# 7 - Use Herbert as a library dependency

Date: 2019-Dec-20

## Status

Accepted

## Context

The Horace and Herbert projects are tightly coupled. Herbert build artifacts are required for integration and MATLAB testing of Horace source.

Changes made to Herbert may change or break dependent MATLAB or C++ code in Horace.

## Decision

To make the depdencency explicit Herbert will be regarded as a library.

As a consequence:

- Herbert builds will NOT trigger Horace builds

- Horace builds (both `PR` and `master`) will always use the latest `master` build of Herbert
- Build artifacts will will copied from the latest successful `master-<target-os>-<target-matlab>` build on the Herbert CI server.

## Consequences

Herbert pull-requests must be completed before the corresponding changes to Horace.

Where Herbert changes introduce "breaking" changes to Horace, CI builds of Horace will be expected to fail until the corresponding changes are merged.

Integration must be tested locally before Herbet changes are merged.

The `copyArtifacts ` Jenkins plugin must be available.