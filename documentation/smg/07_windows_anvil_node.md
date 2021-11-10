# Windows Anvil Node

The document describes mainly existing Windows Anvil node `ndw1676` but may be applicable to any Windows node,
to be added to Jenkins as a slave.

The current Windows Anvil Jenkins slave node is `ndw1676` windows machine located in R3 office UG14.

Some subnets in ISIS may not propagate hosts names so current address this node within
local network is `130.246.49.165`.

The node is available on [Anvil](https://anvil.softeng-support.ac.uk/) as **PACE Windows (Private)**

The following packages are necessary to run a Windows machine as ANVIL node for PACE:

Maltab (appropriate version)
git for Windows
Visual studio 2019 community edition (C++ tools are probably sufficient but did not tried)
Java community edition (GPL Java from https://jdk.java.net/java-se-ri/17 was working fine)

A local `Jenkins` account is enabled for non-admin users. Users can log on via Remote Desktop Connection using this account (as `ndw1676\Jenkins`) providing the agreed local password.
To allow doing that, Jenkins account is configured as the member of "Remote Desktop Users" group on this computer.

To be able to run under scheduler without need to log-in as Jenkins, the Jenkins account has to be assigned 
'Logon as a batch job' permission, which is done in **secpol.msc** management script under `User Rights Assignment`

A number of Matlab versions are installed in `c:\programming\Matlab[Year][Arch]`
(i.e. `c:\programming\Matlab2019b64` or `c:\programming\Matlab2015a32`). These use ISIS floating licenses. If other Matlab versions are necessary, they should be installed alongside (needs administrative rights to do that).

The process of installing Horace for testing is described on the Horace Wiki [Horace Download and Setup for non-default installation](http://horace.isis.rl.ac.uk/Download_and_setup#Installation_with_Horace_not_initialized_by_default_on_starting_Matlab) page. It should be modified according to Anvil job requests.

The Anvil Java client together with a `.bat` file to run it currently located in `D:\Users\Jenkins`
folder.

The Anvil Jenkins client, used by this batch file can be downloaded from [ANVIL](https://anvil.softeng-support.ac.uk/jenkins/jnlpJars/agent.jar). To connect the machine to Anvil, one should run this agent using the command:

```
$>PATH_TO_JAVA\java -jar agent.jar -jnlpUrl https://anvil.softeng-support.ac.uk/jenkins/computer/PACE%20Windows%20(Private)/slave-agent.jnlp -secret XXX_long_secret_key_obtained_from_Anvil_and_specific_to_win_node_XXX -workDir "."
```
which is done in the above mentioned file. The connection addresses for Windows nodes and their secret keys are provided by Anvil support team on request when a node is ready to connect to Jenkins

The batch file currently is running in the scheduler so is started as soon as the windows machine is up.
It tries to restart the job every file minutes in case job script crashes.

The batch file supposed to be run in scheduler or as a service as soon as the Horace Build job setup is completed.
