# Test data storage, distribution and requirements for PACE project

Date: 3-11-2021

## Introduction
Data for Horace tests is currently stored in the repo, which has implications for the data size required for upload, download and storage.
This document describes these issues in detail, provides requirements for alternative storage location and gives possible alternative storage strategies".

## Current State
Currently, the test data are stored on the GitHub Repo as part of the Herbert/Horace project. 
Anyone who clones the GitHub repo also clones all test data and the history of binary mat files.

All users of the GitHub version have direct access to the test data, and said data are created on the local machine in the correct (searchable) locations.

## Issues
* Cloning the repo can take excessive time and Repo is approaching 1GB in size. 
  Because of their binary format, git cannot easily calculate the diffs and as such will store multiple full copies in the history.
* In order to remedy this, a workaround has been performed 
  (removing copies from the history) on a semi-regular basis which requires all branches to be saved, pulled and merged; 
  this can result in corruption if care is not taken.
* Future requirements of the project include benchmarking. 
  Should benchmarking tests require large data (likely), these should not be stored in the repo for the above reasons.

## Requirements
* It is not necessary that the data should be secure/private and does not require special considerations, however, write-access should be protected.
* The data must be accessible to any Jenkins CI machines.
* The data should be accessible to developer machines or at least IDaaS.
* The data might want to be accessible to standard users to verify their PACE install.
* Data should be programatically retrievable (particularly important for CI testing)
  either through shell or through mounting virtual drive.

## Potential solutions to issues
## FTP server
Externally accessible FTP server to store and recover files. 

### Pros
* This can be made globally accessible to anyone who needs data.
* Can be linked into CMake with possibility of only pulling test data if deemed necessary.

### Cons
* Files may have to be manually copied to the correct locations (possible through CMake)
* Requires management/support of external server.
* Trickier to manage version control which may result in inconsistencies between current code state and test data.

## SAN Storage
Discussions have been held regarding migrating test data to the Storage Area Network (SAN). 
Data can be moved across to the SAN and treated like local drive. 
Instructions on how to gain access to the SAN can be found [here](https://github.com/pace-neutrons/Horace/blob/master/documentation/smg/10_how_to_use_the_SAN_area.md).

\<Unsure what discussions have resulted in\>

### Pros
* SAN exists and managed.
* Data appears as though local drive.
* Don't necessarily have to store data copies on local machines.
* Can be selective about data copied to local machine.

### Cons
* Inaccessible to external users to test install.
* Can be complex to connect to SAN drive(?)
* Issues with CI system connecting to remote drive(?)
* Trickier to manage version control which may result in inconsistencies between current code state and test data.


## GitHub LFS
Git has an extension for Large File Storage (LFS), 
which could be used to track and store data as part of the git repo as we have been currently, albeit more efficiently.

### Pros
* Can be made trivially in existing repo.
* No management/support beyond current repo.
### Cons
* Requires extra git extension to manage for all developers (`git lfs install`).
* Requires extra git command to handle large-data (`git lfs track "*.psd"`).
* Costs money ($5/month for 50GB storage and 50GB of transfers) if using Github provided servers.
* Some effort to manage a LFS file server (e.g. on SCD cloud) otherwise.

## Separate test data repo
It is also possible to set up a separate test data repo to store and track test data which may be pulled as submodules within the main git repos.

### Pros
* Don't pull all data unless necessary.
* Can be managed through CMake to only pull relevant data.

### Cons
* Requires awareness on part of user of git submodules.
* Default behaviour with git is to pull submodules (extra awareness).
* Submodules are a mess.

## STFC Cloud Storage
An FTP or LFS server can be run on the [SCD Cloud](https://openstack.stfc.ac.uk/) with attached CEPH storage.
This could be made world-accessible (public IP).

### Pros
* Most flexible
* Satisfies all requirements
### Cons
* Requires effort to maintain the server.
