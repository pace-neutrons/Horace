# Development Environment

## Scope

This document describes setting up a Horace/Herbert environment for new starters at STFC/ISIS.

This is version 1 by Chris Marooney. Composition date 15/9/2020.
At the time of writing, my available hardware was a personal laptop;
an STFC laptop will not be available for some weeks.
This affects my choice of environment.

## Dependencies

The following system requirements are detailed individually below as they are used,
but are summarized here for convenience:
- cmake (3.7 or greater)
- Visual Studio (2017 or greater; for Windows)
- g++ (for Linux)
- Matlab (R2018b or R2019b,from the STFC-specific page.)

## Environments

Available environments are:

- Personal laptop with Windows 10 working from home.
- IDaaS (ISIS Data Analysis as a Service) VM running linux.

The following steps may vary according to your environment;
please select appropriately.

## Getting Horace and Herbert

The overall Horace application lives in two separate repos.
Horace is the main repo for Horace application functionality.
It has a runtime dependency on Herbert, which provides utilities which enable Horace to run.
Note that there are some Herbert runtime dependencies on Horace; there are open tickets to deal with this.

Developers should obtain the code from the git repos: 

* Register with github, which holds the code repos.
Create a new user on github with your STFC email.
Ask the team lead (whoever that is) to allow you appropriate permissions to the project
which is https://github.com/pace-neutrons.
* In a terminal (IDaaS) or command window of your preference (PC - I was using git bash),
create a suitable directory to hold the repo clones.
I used (under my home directory) `mkdir [-p] pace`.
Then within the `pace` directory, clone each of the repos separately:
  * `git clone https://github.com/pace-neutrons/Herbert.git`
  * `git clone https://github.com/pace-neutrons/Horace.git`

Other routes for getting the code exist,
e.g. the download link in the Wiki noted in the next section.
These may not be up to date or are otherwise incomplete;
their use is not advised.
They are intended only for external users.

## Documentation outside the code

The Wiki http://horace.isis/rl.ac.uk provides information on the functionality of Horace.

There is also a demo which will be documented below as part of _Testing the Installation_.

## Repo contents

The repos contain code, data and documentation.
To run the code with the data, you will need to set up a run environment using the steps in the following sections.
To understand what can be done, and what it is planned to do, you should look at the documentation available.
There is a documentation folder in Herbert,
and within the Horace documentation folder there are a number of sub-folders cryptically named.
`smg` is System Maintenance Guide.
`add` is Architecture Design Documents.
`adr` is the set of Architecture Decision Records.
The smaller folders are: `stp`, the System Test Plan,
and `dod`, describing the Definition of Done used on project tasks. 

## Personal laptop environment

At the time of writing it is unclear if a proper STFC laptop will have different properties from using a personal laptop,
or if home working will have different properties from working on-site.
This description refers to a personal laptop working from home.

### Access

* Using the STFC websites requires use of a VPN.
There are a number of possible setups; the one described here is apparently not the most proper but works.
You may already have done this to get email etc.
* Steps:
  * From the Windows Start button navigate to Control Panel.
  * In Control Panel under Category view, select Network and Internet, then Network and Sharing Center.
  * Click the link Set up a new connection or network.
  * In the new window, select Connect to a workplace, click Next
  * Click on the selection Use my Internet connection (VPN)
  * For Internet Address, use VPN.STFC.AC.UK. For destination name, use CICT VPN.
  * If you see Next, click on it and fill in your federal ID and its password, with domain CLRC, click Finish.
  * If you see Finish immediately, go to the Control Panel VPN page.  You will see CICT VPN near the top of the page.
  Click it to reveal Connect, Advanced options, and Remove button.
  Click Advanced Options, where you can fill in the ID, password and domain.
  * Click Connect to establish the connection. This may need refreshing daily, or after shutdown or sleep, or just sometimes.
  Check back to the VPN page; if the Connect button is visible, you are not connected even if your email is working.

### Getting MATLAB

MATLAB can be found at STFC RAL IT Support (Knowledge Base/MATLAB) at www.facilities.rl.ac.uk/itsupport/KnowledgeBase/Matlab.aspx.
This should set up an account with Matlab with your STFC email as id and a password of your choice.
A license is obtainable from the link on this page. For STFC staff members, this should be an individual license.
You can then go to the Matlab download page for STFC and download;
choose R2018b or R2019b, which are the current versions supported at the time of writing.
Or update to more recent if we have changed. This will give you an installation executable.
For other users e.g. contractors, please use the concurrent license by following the instructions.
If these are unavailable due to insufficient access, please ask a colleague staff member
for the relevant instructions from that page - location from which to mount the ISO,
which also provides the temporary license for use in the installation,
and the installation key for your chosen version.
Emailing the FIT helpdesk will provide this information if a colleague cannot do so.

Running the executable will download the files and install.
You may be asked for activation details from Matlab.
This will be your id and password as above.
You are getting an academic individual STFC licence.
Activation may also be required on first launch.
Ideally you will be logged in as you with appropriate privileges.
If not, you may need to run as administrator;
not doing so puts you in an infinite loop of activate, launch, activate, launch.....

This appears to be a one-user license
and I am not necessarily expecting that you will be able to install on multiple machines e.g. personal and work machine.
But it may work.

NB I had problems trying to restart the download - it said I did not have access rights.
Clearing cookies from the page solved this.

### Using MATLAB

#### Prerequisites

* You need to install `cmake`.
I installed the current (at time of writing) version 3.18.2;
there is a minimum version but all current versions should be OK for this.
Select that `cmake` is on the path.
* You need to install the Visual Studio SDK.
This can be the actual SDK or a working VS installation.
I installed Visual Studio 16 2019 community edition (it's free). You can download this at https://visualstudio.microsoft.com/downloads.
It is not clear how the C++ SDK is currently accessible from Microsoft - this appears to be a moving target over the years.
But it is available as the VS 2017 version from "Chocolatey" on https://chocolatey.org/packages/visualcpp-build-tools. NB I have not tried this.
At the time of writing, running `build` with compiler defaults will expect to find a VS2017 compiler,
and will fail even if a more recent compiler is present but not 2017.
Ensure that your compiler is explicitly selected as in the next instruction.
* You need to build Horace and Herbert.
With both cloned as in the instructions above, open a Powershell and cd to the main Horace repo directory.
Then type
  * `.\tools\build_config\build.ps1 -build -vs_version 2019` (Option `-vs` may be used for short.)
* The build will tailor the `horace_on` and `herbert_on` commands to fit the location of the current repo.
* You can now access Horace: within Matlab, cd to Horace\build\local_init and type `horace_on`.
To avoid this indirect access, you can set this directory to be searched
by setting the environment variable MATLABPATH to the full directory path before launching MATLAB.
`horace_on` can then be used immediately on launch.

## IDaaS environment

### Access

* Location for login and registration is https://isis.analysis.stfc.
This should open on the login page - as a new user you may get more info going directly to the registration,
but if you don't, the FAQ menu at the top will take you to a page
with "How do I get a user office account" three quarters of the way down the left "Contents" sidebar.
This section has a link to a page with sign-in and registration areas.
At the bottom right of the page, click on "Create a new facility user account with us".
* On this registration page, fill in the form.
Email should be your STFC email.
For "Facilities You Use" select ISIS.
Click "Create New Account" at the bottom.
You will probably get an email from FacilitiesBusinessSystem@stfc.ac.uk asking you to validate your account - please do.
* After this you should be able to log in and create a password.
Login is your STFC email address. Your password will NOT be your federated password; you need to choose an alternative.
You already have your federated password for access with your federated user id (form: aaa11111),
and a UKSBS Oracle password for access with your Oracle user id (form aaaa11@ph.rc).
Choose whatever password (existing or new) you think is appropriate for this additional login which is not the same as the other two.
NB the federated password never seems to change but is obscure; you have to change the Oracle password every 90 days.

### Opening a VM

* You will see a page "Analysis Environments" hopefully open at the second tab "Analysis".
You will see at least one choice "Excitations Single Crystal".
Pull down `Launch` at the bottom right of the page and select "Open in Browser".
You should get a new window with a Linux desktop.
* In the VM desktop, the Applications menu is bottom left on a taskbar,
followed by icons for your open windows (at the moment you have none).
Click Applications/System to get a terminal.
Click Software/Matlab to get a Matlab IDE window.
Matlab will (at time of writing) be R2018b.
* Note that the Horace item in Applications/Software is the GUI version.
* Note that Matlab will be launched with the system Horace pre-loaded.
To move to a development version, type `horace_off` and the `herbert_off`, change directories to the development version
and type `herbert_init` and then `horace_init` to get Horace loaded from your git repos.

## Testing your installation

Check the location of your Horace by typing `horace_root`.

The Matlab left window for "Current Folder" will show various directories -
drill down into `_test/test_sqw_file`.
At the Matlab command prompt type `s = sqw('_test/test_sqw_file/sqw_1d_1.sqw')`.
This should run and produce some output. Type `s.data` to see the properties created.

There will be an initial warning that the class `hor_config` is outdated and the default will be picked up - this is not a problem.
A new configuration can be loaded with `hc = hor_config`
and the values of `hc` will be printed. The pixel page size in particular may be of use to modify conditions for file backing.

The demo is available from the IDaaS VM by copying the directory `/mnt/babylon/Scratch/Perring/PACE_Tessella` to your home directory.
The subdirectory `user_area`in this contains data (`.sqw` file - may be zipped, use unzip at the command prompt),
Matlab scripts (`.m`  files) and presentations (numbered as well as titled, `.pptx` files).
At the time of writing, the only way I know to get these onto your laptop is to download them.
I use WinSCP. The user id and password are the same as for getting into ISIS Analysis (your STFC email and your chosen password),
and the hostname can be found in the window title bar of the VM browser window -
**NOT** the local name starting `host-192...` which you see in the individual terminal windows.
Port is the default 22. An alternative tool is rsync, which I have not tried. 

The Scratch location for this directory is not ideal, and to provide a more permanent home, 
a zipped copy of this directory is now available at `\\isis.cclrc.ac.uk\Shares\PACE_Project_Tool_Source` (the SAN disk) 
under the directory `PACE_Demo`. This disk is not mounted on IDaaS. 
In the event that the `.../Scratch/Perring` location referred to above or its contents become unavailable, 
the zipped copy can be copied back to the `babylon` disk from our Windows server machine. 
This can be accessed by Remote Desktop. The computer name is the IP address `130.246.49.165` and 
the user name is the communal user `NDW1676\Jenkins`. A colleague will be able to tell you the password. 
Note that one or more colleagues may be using this machine - 
i.e. you may see the desktop populated with working windows. 
If you minimize any that are in the way and confine yourself to launching one or two explorer windows 
to do the file transfer, that should be fine.

The required drives are already mapped. 
`N:` maps to `\\Olympic\Babylon5`, which is the location of the `babylon\Scratch` directory. 
`Z:` maps to the SAN disk. 
You should be able to use these to make the copy to (say) 
your own subdirectory of `babylon/Scratch` (here `N:\Scratch`).
Note that you can access the SAN disk from your own machine by mapping a network drive.
Here the user id is `clrc\myFedID` where myFedID is your normal federal ID for login, 
and the password is your normal federal password. An administrator should already have added you 
to the list of allowed users for the SAN disk.


