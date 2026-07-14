##########
Known bugs
##########

We will endeavour to ensure that Horace reaches you in a fully usable state. However, as more people start to use Horace it is inevitable that bugs will be discovered. If you find a bug please email `Horace Help <mailto:horacehelp@stfc.ac.uk>`__ so that we can ensure it is fixed in subsequent versions of Horace.


Current issues
==============


Symmetrisation problem with dnd data
************************************

We have found that if you symmetrise a dnd dataset by specifying a mirror plane through which the data should be folded, the results are not always correct. In particular, this seems to occur for samples where the crystallographic axes are non-orthogonal. Our recommended solution to this is only to perform symmetrisation operations on sqw data objects, and not on dnd data objects, since the sqw routines work differently to the dnd ones and do not display the same problem.


Broken pipe error
*****************

During the generation of particularly large SQW datasets, which is a computationally intensive process, MS Windows can sometimes just give up. This is evidenced in a so-called 'broken pipe' error, whereby low-level Matlab functions fail to execute due to the failure of very low-level Windows operations. At present we do not have a full fix for this, however it has been found that the following can help rectify the problem:

1. **Run your Horace command again**, after typing

   ::

      >> fclose 'all'


   This command ensures that all open files are closed, as there is a limit on the number of open files Matlab can deal with. You should then run your ``gen_sqw`` again. Sometimes it will fail again, having got slightly further than the previous time (e.g. 80% of the files dealt with, as opposed to 65% before). In these cases you should use the procedure described above several times. With each iteration the command gets closer to finishing. If the command does not get any closer to finishing, even after trying the above several times, then try step 2.

2. Save your work, **close Matlab**, and then re-open Matlab. Note that when you have closed Matlab you should check that all Matlab processes have finished by opening the Windows Task Manager (``Ctrl-alt-delete``) and checking that no processes involving Matlab are still running. In your new Matlab session try running your command again. Again, you may have to try this several times before things start to work... If you still have not success, then try step 3.

3. **Restart Windows**. If the two procedures detailed above do not work then try rebooting and starting again.


Fatal Read Error
****************

Similarly, this sometimes occurs during the writing of data into the SQW file. There are a variety of causes, some understood and some not.

1. One or more of the TMP files has been corrupted. In this case there is little you can do other than to redo the :ref:``gen_sqw`` command. If only one TMP file is corrupted then you may wish to consider re-writing the SQW file without that dataset. To do this use the ``write_nsqw_to_sqw`` command, described `here <List_of_functions:write_nsqw_to_sqw>`.

2. We have found that if you combine SPE files using, for example, ``add_spe`` in Mslice then you can get an inconsistency in the TMP files. We have not yet tracked down the cause of this problem, so at present the solution we propose is **DO NOT** combine SPE files and then make an SQW file out of them. Rather keep the files separate and assign the same values of Ei and psi to them, as Horace will combine the data and recalculate the errorbars internally.
