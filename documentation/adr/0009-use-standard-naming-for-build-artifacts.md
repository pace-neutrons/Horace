[<-previous](0008-use-pipeline-builds.md) | next->

# 9 - Use standard naming for build artifacts

Date: 2020-Jan-19

## Status

Accepted

## Context

The continuous builds (of `master` and the pull requests) will create many release artifacts containing the archived (`.zip` or `tar.gz`) source and binary folders.

These should follow a consistent naming convention so that the following can be quickly determined and the required build identified:

- target platform
- build date
- MATLAB version
- whether this is a PR build or branch build.

When production releases are made these build artifacts will be pushed to [GitHub](https://github.com/pace-neutrons).

## Decision

The release files will be named: `<application>-<version>-<target>-<matlab>[-<yymmdd>][-<sha>].<ext>`

- Release files: `<application>-<version>-<target>-<matlab>`
- PR builds will be:`<application>-<version>-<target>-<matlab>-<sha>`
- Nightly builds will be: `<application>-<version>-<target>-<matlab>-<yymmdd>-<sha>`

| Argument | Description |
|------|-----|
|`version`| `m`.`n`.`o` taken from top ` CMakeList.txt` file |
|`target` | `win64`, `osx` or `linux` |
|`matlab` | MATLAB version, e.g. `2018b` |
|`ext`    | `.zip` will be used for Windows releases; `.tar.gz` for MacOS and Linux |

## Consequences

Developers and users with multiple release files can identify the providence of each.

Naming scheme is trivially extensible to other platforms as they become available (e.g. `scarf`)

The use of a specific the generic `linux` in the `target` depends on the releases being portable between Linux flavours. If issues arise as a result of his we can extend the pattern and create release name/version  specific `target` tags.
