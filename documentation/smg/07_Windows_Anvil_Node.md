# Windows Anvil Node

Currently this node is ndw1676 windows node located in R3 office UG14.
Some subnets in ISIS may not propagate hosts names so current address this node within 
local network is 130.246.49.165.

Local Jenkins account there is enabled for non-admin user Jenkins.
The RDC login to the machine as this user is enabled 
and user should login as ndw1676\Jenkins providing the agreed local password. 

Number of Matlab versions there is installed in c:\programming\Matlab[Year][Arch] 
(i.e. c:\programming\Matlab2019b64 or c:\programming\Matlab2015a32) 
and uses ISIS floating licenses. If other Matlab versions are necessary, they should be 
installed alongside (needs administrative rights to do that)

The process of installing Horace for testing is described on [Horace Download and Setup for non-default installation](http://horace.isis.rl.ac.uk/Download_and_setup#Installation_with_Horace_not_initialized_by_default_on_starting_Matlab)
page. It should be modified according to Anvil job requests.

The Anvil Java client together with bat file to run it currently located in c:\Users\Jenkins\Downloads 
folder. 

As soon as the machine is set up and running Jenkins jobs as Jenkins user, the 
script should be modified to run as a service. 