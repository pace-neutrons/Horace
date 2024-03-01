# ISIS Release Process

Horace is deployed on iDAAaS system and machines dedicated for Excitations from a single Git repository available 
read-only for Excitations machine users and with read/write access for the members of the Excitations group.
 
As the single place where the Horace code located is available to all machines, the changes to the code made by releasers are immediately propagated to all iDAAaS machines and Horace users.

## Horace installation in ISIS

A common filepath `/usr/local/mprogs/Users` is added to the search path of all MATLAB sessions available to users processing the results of inelastic neutron scattering experiments in ISIS.
 
On the machines managed by the Excitations group, this is achieved by adding this path to the end of the list of paths referenced in the`{MATLAB Installation Folder}/toolbox/local/pathdef.m` file. 

Note that recent iDAaaS virtual machines use a different approach for adding this path to the MATLAB search path.

This path defines the folder containing the Horace initialization script `horace_on.m` which, on execution, adds all folders Horace needs to MATLAB search path and initializes all other Horace variables necessary for Horace operations. (e.g. Horace configurations). This folder also contains the worker script which invokes the `horace_on` script and initializes Horace for all parallel MATLAB sessions. 

Administrative script (Horace developers do not have write access to it) `/var/daaas/dynamic/matlabsetup.m` is executed on start up of MATLAB user sessions of iDAAaS machines and invokes `horace_on` for user sessions dedicated for using Horace. 


## Deploy Location
The repositories with the Horace code on iDAAaS file system are currently located under:
`/mnt/ceph/auxiliary/excitations/isis_direct_soft/` 
A number of the actual repositories are cloned under this location:
The following repositories are currently cloned there:

 -- `Horace_git` -- the repository prepared for recent Horace release. As we have not actually released Horace, `master` is currently checked out there. Horace-4 master have also `Herbert` code included.
 
 -- `Horace_3_6` -- the repository for last release of Horace-3. `horace_3_6_3` branch containing latest bugfix release of   Horace.
 
 -- `Horace_3_2` -- historical Horace release hopefully not used any more
 
 -- `Horace_bugfix` -- the special repository clone, with purpose, described later.
 
 As, previous to version 4, versions of Horace needed correspondent versions of Herbert, four clones of Herbert repositories, corresponding to appropriate Horace repositories are also cloned here, namely: `Herbert_git`, `Herbert_3_6`, `Herbert_3_2`, and `Herbert_bugfix` where the last one is redundant or may be used for propagating bugfixes to previous versions of Horace
 
 
As the physical location of Horace repositories may change and was changing in the past and to maintain compatibility with previous versions of Horace installations on Unix systems, we have agreed that the above locations are accessed by Excitation machines code users through symbolic links created in `/usr/local/mprogs` folder.

The release link pointing to the user's code base is currently:

`/usr/local/mprogs/Horace` -> `/mnt/ceph/auxiliary/excitations/isis_direct_soft/Horace_git/horace_core`,

hiding technical areas from inexperienced users.

To ensure compatibility and smooth user's experience, all code operations should be performed with the simulink path-es, which will remain constant regardless of physical location of the code.


Code base for bugfix purposes is linked directly to the git repository for support team convenience, namely:
`/usr/local/mprogs/Herbert_bugfix` -> `/home/isis_direct_soft/Herbert_bugfix`
`/usr/local/mprogs/Horace_bugfix` -> `/home/isis_direct_soft/Horace_bugfix`

Recent Horace version does not need separate Herbert, so only second link should be used for running bugfix code.
The code is invoked by users by calling `horace_on` with the path to `Horace_bugfix` folder, i.e executing: 

`>> horace_on("/usr/local/mprogs/Horace_bugfix")`

script.


## Deploy Process

As soon as release branch is tagged and created in the repository, manual build/release process is preformed in the private area of iDaaaS machine to obtain release artefacts for the iDAAaS computational service. The artefacts mainly are the  compiled mex code routines written to improve the performance of Horace algorithms plus generated `herbert_get_build_version.m` routine providing release version to the Horace code.

It is also possible to pull the release artefacts from Jenkins builds, though this process needs thorough testing. 

Releaser needs special machine, configured with at least C++ compiler, MPI libraries(MPICH-3.6) and CMAKE(optionally, Horace build scripts are also available) to build release artefacts as these packages are not available on a standard Excitation machines. The process of building these artefacts in more details is described [elsewhere](10_build_release_process.md). If releaser builds release artefacts directly on `Horace_git` code tree, CMAKE or `horace_mex`/`horace_mex_mpi` build scripts copy the artefacts into appropriate places of the release code tree. If the build is performed in privately cloned repository (recommended), the artefacts are created in this repository and should be copied to the release code tree manually. Similar copying should be done, if packed release is downloaded from GitHub release pages. 

The mex-code artefacts are located in `{Horace root folder}/horace_core/DLL` folder and release version is a simple generated MATLAB function `herbert_get_build_version.m`, located in `{Horace root folder}/herbert_core/admin/` folder.

The extraction of the release artefacts will be automated in future, as [iDaaaS testing pipeline](https://github.com/pace-neutrons/Horace/issues/271) is implemented.

The releaser then manually checks out the release branch into `Horace_git` areas above and copies the release artefacts into appropriate places of the code tree.

Minor changes and bugfixes do not need the rebuild of the release artefacts and are performed by pulling recent (tested) merges to the release branch into `Horace_git` repository as these changes do not usually involve changes to C++ routines.

## Horace-4 Transitional period

While Horace-4 is undergoing pre-release process, it is expected to be used alongside the previous version of Horace. This is why Horace master branch is currently checked out at `Horace_git` path (recent Horace is combined with Herbert) and latest (3.6.3) version of Horace/Herbert is checked out at `Horace_3_6` and `Herbert_git` paths. 
Two additional versions of `horace_on` script, namely `horace3_on` and `horace4_on` scripts are available in `/usr/local/mprogs/Users` folder and allow user to switch between different versions of Horace calling appropriate script. `horace_on` script called on startup of MATLAB sessions is currently the direct copy of `horace3_on` script.  It will become the copy of `horace4_on` script when Horace-4 will become the default version of Horace.


## Notes

 The linux file-group which has write access to the Horace repositories is named `standarduser`, and IDAaaS support is responsible for adding users to this group. Contact supportanalysis@stfc.ac.uk to be included in this group and obtain write access to the repositories. Normal users have read-only access to the code area, sufficient to use the code in their computations.


#### Contact

iDaaaS support team : support@analysis.stfc.ac.uk


## SCARF

 Horace is currently not available on SCARF and the remainder of this chapter is the previously existing text in the file. It is hence not verified and probably incorrect. This was working in the past and will probably be organized in some similar way in a future. 
 
#### Contact

The deployment on scarf is currently experimental. Generally speaking, user can make local installation of Horace/Herbert as described on [Horace installation pages](http://horace.isis.rl.ac.uk/Download_and_setup) and [SCARF user pages](https://www.scarf.rl.ac.uk/)

Horace parallel capabilities for SCARF are currently implemented on the basis of Matlab MPI framework only. The installation of appropriate cluster component on SCARF and SCARF cluster configuration should be agreed with Jon Roddom<JONATHAN.RODDOM@STFC.AC.UK> or other members of SCARF support team. 

As soon as appropriate SCARF cluster configuration is available to user's Matlab, it must be made default in Matlab parallel computing toolbox settings. Then MATLAB MPI framework (parpool framework) will submit and run parallel jobs on SCARF.

