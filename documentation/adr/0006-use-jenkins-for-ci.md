[<-previous](0005-use-gtest-in-cpp-tests.md) |[next->](0007-use-herbert-as-library-dependency.md)

# 6 - Use Jenkins for CI

Date: 2019-Dec-20

## Status

Accepted

## Context

A Continuous Integration (CI) server is essential for maintaing build quality and creating reproducable builds. The build agents will need access to MATLAB licenses.

Options considered:

- [Anvil](https://anvil.softeng-support.ac.uk/) is a service run centrally by STFC, based on Jenkins, with access to third party software for STFC staff and colleagues.
- [Travis](https://travis-ci.org/) is a cloud hosted CI service, free for Open Source projects.
- Create a private Jenkins instance for the PACE project.

## Decision

We will use the Anvil managed Jenkins instance for build and testing. 

The use of Anvil removes any complications with the avilability of specific target platforms and MATLAB licensing on build nodes. 

- The service has access to pool of STFC MATLAB licenses. 
- Additional build nodes can be provisioned and added to the pool if currently unsupported targets are required.

The overhead of provisioning and managing a private Jenkins instance is not justified at this time.

## Consequences

The PACE team will be depedent on the Anvil administrators to make configuration changes to the Jenkins server (e.g. installing additional plugins).
