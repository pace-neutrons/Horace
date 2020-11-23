# Writing Release Notes

## Release Notes Files

When adding a feature, enhancement or bug fix,
a developer will update the upcoming release's release notes.
The release notes documents are held in `documentation/release_notes`.
There is a release notes file for every major, minor and patch release.
The documents are ReST files and
have the same name as the corresponding release, e.g. `v3.5.0.rst`.

## Recording Release Notes

On every pull request, the developer must consider whether the changes require
documenting.
If the change will affect users in any way, be it a bug fix, a new feature or
an API change, then a sentence or two must be added to the latest release notes
file.
The release notes are intended to be read by users,
so the language used should reflect this.
Use plain English and be brief: try not to exceed 2 sentences.

## Compiling Release Notes

Before the team build/deploy a release,
the release notes document for that release will be tidied.
The most significant changes will appear at the top of the document,
smaller changes and bug fixes will be bullet points at the end.
This document will be published to the user docs when the release is deployed.

A summary of the release notes will also be written.
This document is intended for use on the GitHub releases page.
The GitHub releases pages cannot render ReST,
so the summary document will be written in Markdown.
This document should touch on the main new features and bug fixes
and link to the release notes in the online user documentation.
The summary document has the same name as the main release notes document,
except is suffixed with "*_summary*" (e.g. `v3.5.0_summary.md`).

## Publishing Release Notes

Horace's release notes are published in its online user documentation.
When a release is generated using a `Release-` pipeline,
the release notes are built alongside the rest of the user documentation.
This is then pushed to GitHub to be displayed on `github.io`.
The release notes summary is archived in Jenkins,
for use by the `Deploy` pipeline.

When a release is deployed,
the pipeline will copy the release notes summary file from the `Release-`
pipeline.
The contents of this file is sent in the POST request that creates the release
on GitHub.

When a release is published to users,
the `latest` link in the online user documentation is updated,
by a developer, to point to that release.
