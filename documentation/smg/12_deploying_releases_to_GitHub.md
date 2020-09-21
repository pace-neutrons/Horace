# Deploying releases to GitHub

## ci-release-deploy Repository

A repository
[ci-release-deploy](https://github.com/pace-neutrons/ci-release-deploy)
has been created to hold the code that implements the deployment pipeline.
This decision was made so that code is not duplicated between Herbert and Horace
and to provide fast checkout times for the deploy pipelines.

## Release Pipelines

The release pipelines in ANVIL's Jenkins server should be used to create release
candidates.
These pipelines have a `Release-` prefix.
The pipelines differ from the master builds in that they ensure the
`-DHORACE_RELEASE_TYPE=release` is passed to CMake.
It also keeps release candidates separate from the nightly master builds.

## Deploy Pipelines

The deploy pipelines created on ANVIL's Jenkins server should be used to deploy
release candidates to GitHub.
Horace and Herbert each have their own deploy pipeline name `Deploy`.
When triggered, this pipeline takes the following parameters:

- `tag_sha`: The SHA of the Git revision on which to create the release tag
- `version_number`: The full version number of the release e.g. `3.4.1`
- `release_job_ids`: The IDs of jobs that contain target release artifacts.
This is a multiline string parameter whose input should have the form:

  ```txt
  <pipeline name> <build number>
  <pipeline name> <build number>
                ...
  <pipeline name> <build number>
  ```

  where, for example,
  `<pipeline name> <build number>` = `Release-Windows-10-2019b 12`.

  This allows the deploy pipeline to copy release artifacts from those builds.

- `release_body`: The description of the release to show on GitHub.
This will usually be release notes.
This should be formatted as Markdown.

- `is_draft`: Boolean switch to mark the release as a draft.

- `is_prerelease`: Boolean switch to mark the release as a pre-release.

- `repo_name`: The name of the repository to create the release on,
i.e. `Herbert` or `Horace`.

## Steps to create a new (non-patch) release

1. Create a branch for the upcoming release named `rel_<major>_<minor>`
e.g. `rel_3_4`.

2. Trigger the release pipelines using the `Release-Trigger` pipeline.
Set the `BRANCH_NAME` parameter to the name of the release branch.
Set `HERBERT_BRANCH_NAME` to the relevant Herbert branch/revision.

3. When the pipelines have run and created the release artifacts,
pass the name and numbers of the release's build jobs to the `Deploy` pipeline.
You must also specify the Git SHA revision to tag on GitHub.
Ensure the parameter `is_draft` is checked/set to true.
This will create a draft release on GitHub and upload the build artifacts to it.

4. Open a ticket titled `Release v<major>.<minor>` on GitHub.
In this ticket, provide a link to the draft release
(this link is not accessible to GitHub users who do not have write access to
the repository).
From here developers can download the release candidates.

5. Developers should perform manual testing of the release candidates.
They should download and install release candidates from the draft release.
An issue must be created for any bug or problem found with the release candidate.
Any such issues should be labelled with the name of the release.
Any pull requests must be opened to merge into the release branch created in 1.

6. After testing has been performed and bug fixes have been merged,
repeat step 2 with the updated release branch.
Again, ensure the release is a draft.

7. Smoke test the new release candidates in the draft release.

8. After smoke tests are complete and developers are happy with the package,
the draft release can be manually published.
