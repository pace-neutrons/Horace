
##############
Developer info
##############


Github
======

The Horace code can be accessed on github where it exists as part of `PACE-Neutrons <https://github.com/pace-neutrons>`__ project. To use Horace you also need Herbert, so you can clone Horace and Herbert from appropritate `Herbert <https://github.com/pace-neutrons/Herbert>`__ and `Horace <https://github.com/pace-neutrons/Horace>`__ Git repositories. To get write access to Horace/Herbert you must request the permission from the repositories administrators. Alternatively, clone project from Master, make your changes to a branch and issue a pull request which will be considered by Horace team.

Horace configuration on `isiscompute <http://www.isis.stfc.ac.uk/groups/excitations/data-analysis-computers/connecting-to-isiscomputendrlacuk-using-nomachine15120.html>`__\ \|\ `iDaaaS <https://isis.analysis.stfc.ac.uk/#/login>`__ servers
==============================================================================================================================================================================================================================================

The technical information on how to configure Matlab to use Horace on `isiscompute <http://www.isis.stfc.ac.uk/groups/excitations/data-analysis-computers/connecting-to-isiscomputendrlacuk-using-nomachine15120.html>`__\ \|\ `iDaaaS <https://isis.analysis.stfc.ac.uk/#/login>`__ severs can be accessed through `this link <http://shadow.nd.rl.ac.uk/wiki/idr/index.php/Using_Matlab_and_access_to_sample_Matlab_scripts>`__


Building Horace distribution kit
================================

`Horace web distribution kit <http://horace.isis.rl.ac.uk/kits/>`__ is provided for users who does not have access or does not want to access Horace on `isiscompute <http://isiscompute.nd.rl.ac.uk/>`__\ \|\ `iDaaaS <https://isis.analysis.stfc.ac.uk/#/login>`__ servers. It is generated from a Horace code by `make_horace_deployment_kit <https://github.com/pace-neutrons/Horace/blob/master/admin/make_horace_deployment_kit.m>`__ script, found within Horace `admin <https://github.com/pace-neutrons/Horace/tree/master/admin/>`__ folder. A developer, who wants to generate `Horace distribution kit <http://horace.isis.rl.ac.uk/kits/>`__ should run this script from Matlab session with the Horace initialized to the version, intended for distribution, and selecting Matlab current working directory located outside of the Horace code tree. Within this directory the script generates number of zip files, corresponding to various `Horace&Herbert distributions flavours <http://horace.isis.rl.ac.uk/Download_and_setup#New_Smaller_Download>`__. These files have to be then placed manually into the folder, exposed to the web through the `Horace distribution kit <http://horace.isis.rl.ac.uk/kits/>`__ link.

Physically, the web folder is currently located on ISIS internal network at **shadow** server and exposed through *\\\\\shadow\\horacekits$* (Horace) and *\\\\\shadow\\libisiskits$* (Mslice) folders. Access to these folders as Windows shares needs developers **federal ID** and password. You may need to ask `Freddie Akeroyd <mailto:freddie.akeroyd@stfc.ac.uk>`__ for write access to the web folders.

`Alex Buts <mailto:Alex.Buts@stfc.ac.uk>`__ usually updates web distribution kit each time Horace **isiscompute&&iDaaaS** version is updated.


Wiki page editing protocol
==========================

(N.B. For Horace web editors only)

First, do NOT use the subsection *edit* links on long pages. Always use the *edit* tab at the top of the page, in order to avoid formatting problems.

In order to ensure that the Horace website remains self consistent, there are several checks you need to make.

- If you need to create a brand new page (use sparingly) for your entry, simply type the URL that you would like it to have into your browser's address bar. This will load a blank page, with the option *create* instead of *edit* at the top.

- Generally, you should try to append your new entry to an existing page. If you create a subheading (see existing pages for code examples) then you can link to this from elsewhere.

- Consider whether your new entry merits an addition to the :ref:`Example_scripts <Example_scripts:Example scripts>` section. If so, make the change. Also add the change to the example scripts held on ISIScompute, to ensure consistency.

- Ensure your new edit, if it describes a new routine, is correctly linked in the :ref:`List of functions <List_of_functions:List of functions>` page.
