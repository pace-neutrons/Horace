[<-previous](0005-pace-projects-must-be-semantically-versioned.md) | [next->](0007-developer-scripts-storage-location.md)

# 6. Store built documentation in branch

Date: 2020-Jun-20

## Status

Proposed



## Context

GitHub Pages support two [publishing sources](https://help.github.com/en/github/working-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site) for project documentation:

- the `docs` folder on the `master` branch
- the root folder of the `gh-pages` branch

a third option is to store the built project documentation in

- documentation GitHub project.



If the built documentation is stored on the `master` branch:

- the codebase includes built artifacts
- any release tag needs to be created on the commit after that from which the build was executed
- requires the CI server to make commits to the `master` branch
- it's straightforward to manage document builds from branches other than `master`



Where the build artifacts on a separate branch:

- harder to compare source with the built documentation and manage the build artifacts from branches,

- cleanly separates build artefacts from source code



Storing built documentations in a separate GitHub repository:

- offers clear separation between source and built documentation
- carries an overhead or managing another repository
- documentation will served at a URL that doesn't match the source: e.g. `pace-neutrons.github.io/horace-docs`



## Decision

Built documentation will be stored on the `gh-pages` branch.



## Consequences

- The build pipeline will need to move the built pages from source branch (`master`) to the publication branch  (`gh-pages`)
- Any previously build documentation for the current project version must be deleted from the `gh-pages` branch.
- Management of documentation builds for non-`master` branch will need to be considered on a per-project basis.
- Non-`master` branch build documentation may be put in named folders on the `gh-pages` branch - these would need to be managed, i.e. deleted after the branch is merged or periodically.