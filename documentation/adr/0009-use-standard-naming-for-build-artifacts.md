[<-previous](0008-use-pipeline-builds.md) | next->

# 9 - Use standard naming for build artifacts

Date: 2020-Jan-19

## Status

Accepted

## Context

The continuous builds (of `master` and the pull requests) will create many release artifacts containing the archived (`.zip` or `tag.gz`) source and binary folders.

These should follow a consistent naming convention so that it can be quickly determined:

- target platform
- build date
- whether this is PR build or branch build.

When production releases are made these build artifacts will be pushed to [GitHub](https://github.com/pace-neutrons).

## Decision

The release files will be named: `<application>-<version>-<target>[-<yymmdd>][-<sha>].<ext>`

- Release files: `<application>-<version>-<target>`
- PR builds will be:`<application>-<version>-<target>-<sha>`
- Nightly builds will be: `<application>-<version>-<target>-<yymmdd>-<sha>`

| Argument | Description |
|------|-----|
|`version`| `m`.`n`.`o` taken from top` CMakeList.txt` file |
|`target` | `win64`, `osx`, `linux` or specific Linux version information e.g. `centos.8`, `scientific.7` |
|`ext`    | `.zip` will be used for Windows releases; `.tar.gz` for MacOS and Linux |

## Consequences

Developers and users with multiple release files can identify the providence of each.

Naming scheme is trivially extensible to other platforms as they become available (e.g. `scarf`)

The use of a specific Linux release name/version in the `target` argument is only required if the builds are not portable between different Linux releases.