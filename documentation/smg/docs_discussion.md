# A place for discussion about how we are going to handle docs

Currently the setup is as follows:
* Docs are stored in separate repo
* Repo rebuilds are manually triggered
* On rebuild specify HORACE_VERSION
   * HORACE_VERSION determines output folder, copies whole html docs to both HORACE_VERSION and stable
* Repo is general write access

I will dicuss each of these in turn. Note that some of these are not mutually exclusive and could be used in combination.

## Docs Repo
### Current state

#### Separate Repo

Basically, the way I see it is that the separate repo allows us more freedom to build in a way in which we don't have to concern ourselves with accidentally disturbing other parts of the Horace project at large. This will serve to replace the wiki as the main docs source, and it might even be best to replace the http://horace.isis.rl.ac.uk/ with a redirect to the docs stable, whatever that may be.

##### Pros:
* Separates build hooks from main PRs
* Prevents accidental damage to main repo on deploys
* Allows documentation of not just Horace, but Herbert without causing confusion if renamed to PACE-docs, etc.

##### Cons:
* Separation may confuse people who want offline docs
* May discourage keeping docs up to date as they are in different project

### Alternatives

#### Unified repo 
Merge horace-docs into Horace branch as docs folder.

##### Pros:
* Locality of code and docs
* Encourage people to update as they code, rather than as an afterthought
* Keeps docs always in-line with the main build commit

##### Cons:
* May confuse builds/deploys (Could be mitigated through docs labels)
* Disallows combination of Herbert/Horace/Entire PACE docs into one place.

#### Submodule
Use git submodules to have the docs as a sub-repo of Horace main

##### Pros:
* Still have the separation of repos
* Docs exist in Horace repo and can be updated/held there

###### Cons:
* Requires knowledge to manage submodules
* May require changing build scripts
* Means that the docs will be up-to-date with latest docs not current Horace commit

## Repo Builds

### Current state
#### Manual trigger
Currently a docs build/deploy is manually triggered from the Jenkins pipeline, which will build and (on build success) deploy to a github.io accessible place.

##### Pros:
* Control over when/where docs get built
* Little risk of accidental destruction of docs site due to manual version specification

##### Cons:
* Requires manual effort to say when to deploy
* Could lead to desynchronisation of repo and site if care not taken 

### Alternatives
#### Build/Deploy on updated main
On every PR merge new build, replacing current docs

##### Pros:
* Keep docs up-to-date when they are updated
* No effort to update docs

##### Cons:
* May lead to damage if docs not verified properly (mitigated by multiple docs versions)
* Difficult to check how branches would appear
* Requires manually updating version number in Jenkins

#### Build/Deploy on Horace release
Tie docs deploy into the existing deploy pipeline such that on each major Horace release docs are released to the right tag

##### Pros:
* Fully automated
* Robust against accidental docs damage

##### Cons:
* Dev docs may grow out of sync in time between major releases
* Dev docs may be difficult to track

## Docs versioning
### Current state
#### Version folder and stable folder
Currently we have a folder for each version and stable both updated/overwritten on a deploy

##### Pros:
* Easy to track
* Pre-release can be set up as a prVersion and cleaned up on release

##### Cons:
* Manual cleanup of PR
* Extra effort to make dev changes public

### Alternatives
#### Unstable, stable, version
Have an unstable (dev) folder which is updated every push, stable updated on release and version updated every push

##### Pros:
* Dev changes immediately update through unstable version
* Stable version for users directs to most recent

##### Cons:
* More Jenkins logic required
* Extra folders

#### Dev, Version
Only have version number and dev version users look up their version

##### Pros:
* Users of old versions have no confusion on release update
* Dev changes visible

##### Cons:
* No short cut to latest version (need to know your version)
* Discourages users staying up to date?

#### Per-branch docs
Each branch gets built as branch-docs (mostly relevant if horace-docs merged into main) 

##### Pros:
* Automatically labelled and searchable
* All docs build and are reachable

##### Cons:
* Cleanup of merged/deleted branches
* Users may not know which branch is relevant
* Too many docs

#### Per-tag docs
As above, but with each milestone/tag

##### Pros:
* As above
##### Cons:
* As above

## Stable/Dev status
### Current state
#### Full folder copy
Currently the stable docs are a full copy of the html folder

##### Pros:
* Hyperlink says stable, not version number

##### Cons:
* Potential to become out of sync
* Difficult to redirect stable without full rebuild/deploy

### Alternatives
#### Redirect
Just have an HTML redirect file to the lates

##### Pros:
* Easy to update/fix and can be separated manually from deployment procedure
* Still easy to automate if desired

###### Cons:
* Address bar may not show stable on redirect causing confusion

#### Symlink (shortcut)?
Have a stable folder which links to version without 

##### Pros:
* All of redirect
* Address bar correct

###### Cons:
* Not sure if possible

## Repo access
### Current state
#### Open
Full write access to main

##### Pros:
* Easy to force an update through

##### Cons:
* Easy to force an update through

### Alternatives
#### PR required
Disable pushing to main

##### Pros:
* Follows git best practices
* Prevents risk of major damage to main docs
* Encourages review process
* Enables easy squashing of commits while fixing things

##### Cons:
* Requires personal fork/branch
