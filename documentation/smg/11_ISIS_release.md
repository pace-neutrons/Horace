# SMG-11: ISIS Release Process

Horace is deployed separately to a number of systems across ISIS. These are


## ISIS Compute

#### Contact

FBU IT support team: FBUitservicedesk@stfc.ac.uk 


#### Deploy Location
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

## IDAaaS

#### Contact

iDaaaS support team : support@analysis.stfc.ac.uk

#### Deploy Location

physical location is the same as on ISISCOMPUTE, except ISISCOMPUTE file system is currently mounted on iDaaaS at `/mnt/nomachine`. This can change in a future, but by agreement with iDaaaS team, the symbolic links in `/usr/local/mprogs` will always point to a physical location of appropriate Horace/Herbert repository clones. 

To ensure compatibility and smooth user's experience, all code operations should be performed with the simulink path-es, which will remain constant regardless of physical location of the code.

#### Deploy Process

The process is currently absolutely the same as on ISISCOMPUTE. The real ISISCOMPUTE and virtual IDAaaS machines are currently share the same OS version and the same file system, so the deployment, performed on one system currently means the deployed on another and have to be done only on one system. 

The disadvantage of iDaaaS is currently the absence of the system-wide cmake installation, so a person, who wants to make a release on iDaaaS machine needs to do local cmake installation.

#### Notes

The write access to code repository on iDaaaS is granted by iDaaaS team on request. Currently the list of people, who has the write access coincides with the members of **mslice** group on ISISCOMPUTE. This may change in a future. 



## SCARF

#### Contact

The deployment on scarf is currently experimental. Generally speaking, user can make local installation of Horace/Herbert as described on [Horace installation pages](http://horace.isis.rl.ac.uk/Download_and_setup) and [SCARF user pages](https://www.scarf.rl.ac.uk/)

Horace parallel capabilities for SCARF are currently implemented on the basis of Matlab MPI framework only. The installation of appropriate cluster component on SCARF and SCARF cluster configuration should be agreed with Jon Roddom<JONATHAN.RODDOM@STFC.AC.UK> or other members of SCARF support team. 

As soon as appropriate SCARF cluster configuration is available to user's Matlab, it must be made default in Matlab parallel computing toolbox settings. Then Maltab MPI framework (parpool framework) will submit and run parallel jobs on SCARF.

