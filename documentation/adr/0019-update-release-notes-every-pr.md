[<-previous](./0018-algorithm-migration-to-paged-files.md) |
[next->](0020-use-c-mex-api.md)

# 19 - Update Release Notes on Every Pull Request

Date: 2020-Nov-19

## Status

Accepted

## Context

Following the release of v3.5.0 of Horace,
it was found that breaking changes were not effectively communicated to users.
A discussion on the best way to communicate these changes,
as well as the best way for developers to track such changes, was had.
It was decided release notes provided a solution to this problem.

The workflow for producing release notes needs to be decided.

## Decision

A file is to be kept in the repository to track changes between releases.
This file is to be updated on every pull request in which:

- an API change is made.
- a feature is added.
- a user-facing bug is fixed.

Additions to the file will be written as if addressing users.
These additions will document behaviour changes,
as well as changes users will be required to make to their workflows/scripts.

Before every release, this file will be used to compile release notes.
These release notes will be published alongside releases on GitHub
and with user documentation.

## Consequences

- Developers will be required to update the release notes document for every
  user-facing change.
  Reviewers will also be responsible for ensuring release notes are created
  when required.
- A comprehensive list of changes for each release is kept.
- Merge conflicts may become common as the release notes file is updated often.
