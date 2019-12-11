# Distributing Horace to users

Current Horace distribution process uses two channels, 
which allows us frequently modify the code,
satisfy the requests of different groups of users and rapidly react to the bugs, 
encountered by users running their experiments in ISIS. The distribution is deployed 
from live Horace/Herbert code tree after a developer added the requested features and 
run existing unit/system tests ensuring no trivial bugs are 
introduced at the development stage.

The channels are the *compressed zip archive* downloaded from the web and intended for external users
and *updates to git **production** branch* checked out to parallel file system and intended for the users,
who are doing experiments in ISIS.


## Zip archive channel.

The process of installing zip-archive from the user perspective is described in details at 
[Horace Distribution page.](http://horace.isis.rl.ac.uk/Download_and_setup)

To synchronize zip-archive distribution channel with the production branch distribution channel, 
developer should merge all necessary changes into the production branch of the git archive
and do the following work from this branch. (Horace and Herbert production branches together)

After ensuring that all tests are passing on the production branches, the developer should leave 
the Horace/Herbert code tree and move his Matlab working folder to a temporary location, 
where the Horace distributive can be temporary placed. Normally this folder could be user home directory,
 e.g. `cd ~` on Unix or `cd c:\Users\UserName\Documents\MATLAB` on Windows. After that, he runs the 
[`make_horace_deployment_kit`](https://github.com/pace-neutrons/Horace/blob/master/admin/make_horace_deployment_kit.m)
script, which produces 5 archives. The main one -- ***horace_distribution_kit.zip*** containing 
the whole Horace code with demo files and tests and 4 smaller archives, 
the most important one is the small but self-consistent ***Horace&Herbert_NoDemoNoTests.zip*** 
which contains complete working code without tests and demo files. 

Then the developer should log into **shadow.isis.cclrc.ac.uk** and upload these files to 
**/isis/www/horace/kits** folder. This folder is available for downloading from the
web at the location specified on 
[Horace Distribution page.](http://horace.isis.rl.ac.uk/Download_and_setup)

At the moment only Alex Buts (wkc26243) have write access to this folder. The developers who
need write access to this folder should request it from 
Freddie Akeroyd: <freddie.akeroyd@stfc.ac.uk>

The [`make_horace_deployment_kit`](https://github.com/pace-neutrons/Horace/blob/master/admin/make_horace_deployment_kit.m)
script performs the following operations:

 - It runs [update_svn_revision_info](https://github.com/pace-neutrons/Herbert/blob/master/admin/update_svn_revision_info.m) 
   Matlab script, which updates svn revision information in all code files 
   where this info is present, if the key `-update_version` is provided as input. 
   (can be reduced to just `-u`)
 - It runs [`make_horace_distribution_kit`](https://github.com/pace-neutrons/Horace/blob/master/admin/make_horace_distribution_kit.m)
   with different options. This script
   defines the code-tree folders, which should be distributed to users and copies this 
   folders into the current location. The different script options define different amount and type
   of the code to copy to obtain different archives above.
 - Depending on input option, `make_horace_distribution_kit` may deploy 
   [`make_herbert_distribution_kit`](https://github.com/pace-neutrons/Herbert/blob/master/admin/make_herbert_distribution_kit.m)
   script, which does similar operation with Herbert code. 
 - After all necessary code is copied into the temporary target location, the script
   p-codes the specified folders defined by the developer in the script, compresses 
   the files together with their location within the folders tree, 
   and removes target location after compression. 

## *production* branch channel.

After completing the generation of zip code, developer merges the production branch to master and
commits the changes to git.  This brings the updated code to all developers. 

To provide the updated code to the ISIS users, the developer should update the production branch 
checked out to the parallel file system connected to ***isiscompute*** and ***iDaaaS*** machines.
The distributive is physically located on shared parallel file system connected to ***isiscompute***
at */home/isis_direct_soft/*. All other systems including ***isiscompute*** itself refer 
to this branch through symbolic link at

 - */usr/local/mprogs/Herbert -> /home/isis_direct_soft/Herbert_git/herbert_core* 
and
 - */usr/local/mprogs/Horace -> /home/isis_direct_soft/Horace_git/horace_core*. 
 
 The links are used by ***horace_on*** or startup.m scripts executed on user machine as the 
 initial path for Horace/Herbert initialization. 
 
 The branch folder is accessible for writing by the members of **mslice** group on **isiscompute**
 or on request from <support@analysis.stfc.ac.uk> on **iDaaaS**. 
 
 - **Note**: Updating archive on **iDaaaS** prohibit access to **isiscompute** until 
   **isiscompute** *root* returns ownership to **mslice** group. Opposite is not valid.
