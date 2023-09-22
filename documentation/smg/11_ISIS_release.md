# ISIS Release Process

Horace deployed on iDAAaS system and machines dedicated for excitations as a single git repository available 
read-only for excitation machine users and providing read/write access for the members of the excitations group.

As the single place of the Horace code is available to all machines, the changes to the code made by releasers are immediately available to all iDAAaS machines.

## Horace installation in ISIS

Common path `/usr/local/mprogs/Users` is added to the search path of all MATLAB sessions available to users. 
On the machines, managed by excitation group this is achieved by adding this path to the end of the `{MATLAB Installation Folder}/toolbox/local/pathdef.m` file, though recent iDAAaS virtual machines seems use different approach for adding this path to the MATLAB search path.

This path contains Horace initialization script `horace_on.m` which, on execution, adds all necessary folders to MATLAB search path and initialize all other Horace variables necessary for Horace operations. (i.e. Horace configurations). This folder also contains the worker script, which invokes `horace_on` script and initializes Horace for all parallel MATLAB sessions. 

Administrative script (Horace developers do not have write access to it) `/var/daaas/dynamic/matlabsetup.m` is executed on start up of MATLAB user sessions and invokes `horace_on` for user sessions which are dedicated for using Horace. 


## Deploy Location
The repositories with the Horace code on iDAAaS file system are currently located under:
`/mnt/ceph/auxiliary/excitations/isis_direct_soft/` 
Number of the actual repositories are cloned under this location:
The following repositories are currently cloned there:

 -- `Horace_git` -- the repository prepared for recent Horace release. As we have not actually released Horace, `master` is currently checked out there. Horace-4 master have also `Herbert` code included.
 
 -- `Horace_3_6` -- the repository for last release of Horace-3. `horace_3_6_3` branch containing latest bugfix release of   Horace.
 
 -- `Horace_3_2` -- historical Horace release hopefully not used any more
 
 -- `Horace_bugfix` -- the special repository clone, with purpose, described later.
 
 As previous to version 4 versions of Horace needed correspondent versions of Herbert, three clones of Herbert repositories, corresponding to appropriate Horace repositories are also cloned here, namely: `Herbert_git`, `Herbert_3_6`, `Herbert_3_2`, and `Herbert_bugfix`
 
 
As the physical location of Horace repositories may change and was changing in the past and to maintain compatibility with previous versions of Horace installations on Unix systems, we have agreed that the above locations are accessed by Excitation machines code users through symbolic links created in `/usr/local/mprogs` folder.

The release link pointing to the user's code base is currently:

`/usr/local/mprogs/Horace` -> `/mnt/ceph/auxiliary/excitations/isis_direct_soft/Horace_git/horace_core`,

hiding technical areas from inexperienced users.

To ensure compatibility and smooth user's experience, all code operations should be performed with the simulink path-es, which will remain constant regardless of physical location of the code.


Code base for bugfix purposes is linked directly to the git repository for support team convenience, namely:
`/usr/local/mprogs/Herbert_bugfix` -> `/home/isis_direct_soft/Herbert_bugfix`
`/usr/local/mprogs/Horace_bugfix` -> `/home/isis_direct_soft/Horace_bugfix`

## Deploy Process

As soon as release branch is tagged and created in the repository, manual build/release process is preformed in the private area of iDaaaS machine to obtain release artefacts for the iDAAaS computational service. It is also possible to pull the release artefacts from Jenkins builds, though this process needs thorough testing. 
The extraction of the release artefacts will be automated in a future, as [iDaaaS testing pipeline](https://github.com/pace-neutrons/Horace/issues/271) is implemented.

The releaser then manually checks out the release branch into `Horace_git` areas above and copies the release artefacts into appropriate places of the code tree.

Minor changes and bugfixes do not need the rebuild of the release artefacts and performed by pulling recent merges to the release branch into `Horace_git` repository.

## Horace-4 Transitional period

While Horace-4 is undergoing pre-release process, it is expected to be used alongside with previous version of Horace. This is why Horace master branch is currently checked out at `Horace_git` path (combined with Herbert) and latest (3.6.3) version of Horace/Herbert is checked out at `Horace_3_6` and `Herbert_git` path-es. 
Two additional versions of `horace_on` script, namely `horace3_on` and `horace4_on` scripts are available in `/usr/local/mprogs/Users` folder and allow user to switch between different versions of Horace calling appropriate script. `horace_on` script called on startup of MATLAB sessions is currently the direct copy of `horace3_on` script.  It will become the copy of `horace4_on` script when Horace-4 will become the default version of Horace.


## Notes

 The the group which have write access to the Horace repositories is named `standarduser`, and IDAAaS support is responsible for adding users to this group. Contact supportanalysis@stfc.ac.uk to be included in this group and obtain write access to the repositories. Normal users have read-only access to the code area, sufficient to use the code in their computations.


#### Contact

iDaaaS support team : support@analysis.stfc.ac.uk


## SCARF

 This chapter is currently not verified and probably incorrect. This was working in the past and will probably organized in some similar way in a future. 
#### Contact

The deployment on scarf is currently experimental. Generally speaking, user can make local installation of Horace/Herbert as described on [Horace installation pages](http://horace.isis.rl.ac.uk/Download_and_setup) and [SCARF user pages](https://www.scarf.rl.ac.uk/)

Horace parallel capabilities for SCARF are currently implemented on the basis of Matlab MPI framework only. The installation of appropriate cluster component on SCARF and SCARF cluster configuration should be agreed with Jon Roddom<JONATHAN.RODDOM@STFC.AC.UK> or other members of SCARF support team. 

As soon as appropriate SCARF cluster configuration is available to user's Matlab, it must be made default in Matlab parallel computing toolbox settings. Then Maltab MPI framework (parpool framework) will submit and run parallel jobs on SCARF.

