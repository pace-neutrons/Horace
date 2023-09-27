# SMG-11: ISIS Release Process

Horace is deployed separately to a number of systems across ISIS. These are:

- IDAaaS: This is currently the normal access point for users of Horace in ISIS.
- SCARF: This is an alternative HPC environment. In contrast to the deployment on IDAaaS, the current deployment is experimental, and its parallel capabilities are more limited. 
Details of this are given below, including contacts for improving the installation.
- ISISCOMPUTE. This is the base location for code deployed to IDAaaS, and can also be used directly by experienced users only. This section gives reference details
for use of this system. 

This document is primarily concerned with the process of upgrading Horace and releasing new Horace versions on IDAaaS. However, details for how we might update SCARF 
and how experienced users might access Horace through ISISCOMPUTE are also given for completeness.

## IDAaaS

IDAaaS is the cloud computing service "ISIS Data Analysis as a Service" provided by Scientific Computing for ISIS users.
It is accessed from https://isis.analysis.stfc.ac.uk/, from where you can login to the service. It also gives instructions for new users; similar instructions are also available in the
registration part of the dialog on the login page. Detailed use of IDAaaS and Matlab on IDAaaS is outside the scope of this document.

#### Contact

iDaaaS support team : support@analysis.stfc.ac.uk

#### Main Deploy Location

Various versions and componentes of Horace is deployed in a number of local repositories under the path `/usr/local/mprogs`.

The physical disk location of these Horace repositories is the same as for ISISCOMPUTE system; the description for that system below gives more details.
As this may change subject to development of the underlying IDAaaS system structure, the path 'usr/local/mprogs` provides symbolic links to the repositories' current locations.
Note that the repository symbolic link names may not always match exactly the directory name of the underlying repository location.
To ensure compatibility and smooth user's experience, all code operations should be performed with these symbolically linked paths, which will remain constant regardless of physical location of the code.

The principal repositories are
- Horace (underlying name: Horace_git): this is the directory corresponding to `horace_core in a clone of the full Horace github repository
- Herbert (underlying name: Herbert_git): this is the directory corresponding to `herbert_core` in a clone of the full Horace github repository.

#### Main Deploy Process

The version deployed is the one on the master branch of the github repository https://github.com/pace-neutrons/Horace, and the process of deployment for a simple fix is the same as for
fixing or updating the master branch in any development process:
- clone the repository, either to IDAaaS or your own local machine
- create and checkout a new branch referencing a ticket for the changes
- make the changes, and add them and commit them to your repository clone
- push the changes, which should pass all tests and be approved by reviewers before merging into the master branch
- if all tests pass and all reviewers agree, merge the pull request.
The final additional step is to make the changes in github available on IDAaaS; so far they have only been made on github.
- On IDAaaS, open a terminal and change directory to the Horace (Horace_git) repository named above.
- Check the repository's status with the `git status` command, You should find that it is a git repository checked out on the `master` branch. 
For other outputs, please consult with the Horace developers.
- Bring the changes into the IDAaaS repository with the command `git pull`.
- If you have also made changes in the `herbert_core` directory, repleat these steps in the Herbert (Herbert_git) repository. 
Although Horace and Herbert have been merged into a single repository on github, they are stilll represented by two separate repositories on IDAaaS.


The process is currently absolutely the same as on ISISCOMPUTE. The real ISISCOMPUTE and virtual IDAaaS machines are currently share the same OS version and the same file system, so the deployment, performed on one system currently means the deployed on another and have to be done only on one system. 

The disadvantage of iDaaaS is currently the absence of the system-wide cmake installation, so a person, who wants to make a release on iDaaaS machine needs to do local cmake installation.

#### Notes

Write access to code repository on iDaaaS is granted by iDaaaS team on request. Currently the list of people who have write access coincides with the members of **mslice** group on ISISCOMPUTE. This may change in a future. 



## SCARF

#### Contact

The deployment on scarf is currently experimental. Generally speaking, user can make local installation of Horace/Herbert as described on [Horace installation pages](http://horace.isis.rl.ac.uk/Download_and_setup) and [SCARF user pages](https://www.scarf.rl.ac.uk/)

Horace parallel capabilities for SCARF are currently implemented on the basis of Matlab MPI framework only. The installation of appropriate cluster component on SCARF and SCARF cluster configuration should be agreed with Jon Roddom<JONATHAN.RODDOM@STFC.AC.UK> or other members of SCARF support team. 

As soon as appropriate SCARF cluster configuration is available to user's Matlab, it must be made default in Matlab parallel computing toolbox settings. Then Maltab MPI framework (parpool framework) will submit and run parallel jobs on SCARF.

## ISIS Compute

#### Contact

FBU IT support team: FBUitservicedesk@stfc.ac.uk 


#### Deploy Location

, except ISISCOMPUTE file system is currently mounted on iDaaaS at `/mnt/nomachine`. This can change in a future, but by agreement with iDaaaS team, 
the symbolic links in `/usr/local/mprogs` will always point to a physical location of appropriate Horace/Herbert repository clones. 

The physical location of the code on ISISCOMPUTE file system is:

`/home/isis_direct_soft/Horace_git`
`/home/isis_direct_soft/Horace_bugfix`
`/home/isis_direct_soft/Herbert_git`
`/home/isis_direct_soft/Herbert_bugfix`

By agreement, this location is accessed by code users through symbolic links, created in `/usr/local/mprogs` folder.

The release link are pointing to the user's code base, namely:
`/usr/local/mprogs/Herbert` -> `/home/isis_direct_soft/Herbert_git/herbert_core`
`/usr/local/mprogs/Horace` -> `/home/isis_direct_soft/Horace_git/horace_core`

hiding technical areas from inexperienced users.

To ensure compatibility and smooth user's experience, all code operations should be performed with the simulink path-es, which will remain constant regardless of physical location of the code.


Code base for bugfix purposes is linked directly to the git repository for support team convenience, namely:
`/usr/local/mprogs/Herbert_bugfix` -> `/home/isis_direct_soft/Herbert_bugfix`
`/usr/local/mprogs/Horace_bugfix` -> `/home/isis_direct_soft/Horace_bugfix`

#### Deploy Process

As soon as release branch is tagged and created in the repository, manual build/release process is preformed in the private area of an ISISCOMPUTE or iDaaaS machine to obtain release artefacts for the computational service. It is also possible to pull the release artefacts from Jenkins builds, though this process needs thorough testing. 
The extraction of the release artefacts will be automated in a future, as [iDaaaS testing pipeline](https://github.com/pace-neutrons/Horace/issues/271) is implemented. The releaser then manually checks out the release branch into `Herbert_git/Horace_git` areas above and copies the release artefacts into appropriate places of the code tree.

#### Notes

The script which automates these operations and performs internal releases as one-click operation will be developed in the nearest future.

The members of **mslice** group on ISISCOMPUTE have write access to release code areas. Alex Buts or FBU IT support team can currently add users to **mslice** group on ISISCOMPUTE. Normal users have read-only access to the code area, sufficient to use the code in their computations.

