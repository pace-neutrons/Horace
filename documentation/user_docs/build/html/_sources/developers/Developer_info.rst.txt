##############
Developer info
##############


Github
======

The Horace code can be accessed on github where it exists as part of `PACE-Neutrons
<https://github.com/pace-neutrons>`__ project. You can clone Horace from the `Horace
<https://github.com/pace-neutrons/Horace>`__ Git repository. To get write access to Horace you must request the
permission from the repositories administrators. Alternatively, the clone project from ``master``, make your changes to
a new branch and issue a pull request which will be considered by Horace team.

Horace configuration on isiscompute & iDaaaS servers
====================================================

The technical information on how to configure Matlab to use Horace on `isiscompute
<http://www.isis.stfc.ac.uk/groups/excitations/data-analysis-computers/connecting-to-isiscomputendrlacuk-using-nomachine15120.html>`__ &
`iDaaaS <https://isis.analysis.stfc.ac.uk/#/login>`__ servers can be accessed through `this link
<http://shadow.nd.rl.ac.uk/wiki/idr/index.php/Using_Matlab_and_access_to_sample_Matlab_scripts>`__


Building Horace distribution kit
================================

`Horace web distribution kit <https://github.com/pace-neutrons/Horace/releases>`__ is provided for users who does not
have access or do not want to access Horace on the `isiscompute <http://isiscompute.nd.rl.ac.uk/>`__ &
`iDaaaS <https://isis.analysis.stfc.ac.uk/#/login>`__ servers. It is generated from the Horace code by
`make_horace_deployment_kit <https://github.com/pace-neutrons/Horace/blob/master/admin/make_horace_deployment_kit.m>`__
script, found within Horace `admin <https://github.com/pace-neutrons/Horace/tree/master/admin/>`__ folder. A developer,
who wants to generate their own Horace distribution kit should run this script from a Matlab session with the
appropriate Horace version active, and a Matlab working directory located outside of the Horace code tree. The script
generates a number of zip files within this directory, corresponding to the various Horace distributions flavours. These
files are generally built and released using the release pipelines available on the `ANVIL CI
Platform <https://anvil.softeng-support.ac.uk/>`__.

..
   Physically, the web folder is currently located on ISIS internal network at **shadow** server and exposed through
   *\\\\\shadow\\horacekits$* (Horace) and *\\\\\shadow\\libisiskits$* (Mslice) folders. Access to these folders as Windows
   shares needs developers **federal ID** and password. You may need to ask `Freddie Akeroyd
   <mailto:freddie.akeroyd@stfc.ac.uk>`__ for write access to the web folders.

`Alex Buts <mailto:Alex.Buts@stfc.ac.uk>`__ usually updates web distribution kit each Horace release.
