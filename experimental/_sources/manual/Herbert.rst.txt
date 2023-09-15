
#######
Herbert
#######

Herbert is the collection of utilities for visualisation and analysis of neutron spectroscopy data. It can be used alone or as the package, which provide low level data manipulation routines for the `Horace <http://horace.isis.rl.ac.uk/Main_Page>`__ package


It has been extracted from Libisis to simplify Horace installation and can be considered as `Libisis <http://www.libisis.org/Main_Page>`__ stripped of the data reduction capabilities.

Installation
************

Installing Herbert means registering it with Matlab. The procedure is very similar to the one, done for Horace itself so we will refer to it as registering a package. Two methods to register a package are currently used by ISIS. One is based on editing your Matlab startup file, and another one -- by registering small part of the packages with Matlab. The startup.m method is simpler, while registering package_on file provides more flexible results and is necessary if you are intended to use parallel Herbert/Horace capabilities.


Installation using Matlab startup file
======================================

Unzip all of the Herbert folders into a single directory. The directory structure below this will be taken care of by your zip program. On a Windows machines a good place to put this would be somewhere like

::

   C:\mprogs\


On Unix convenient place would be an

::

   ~/ISIS folder.


Now you need to edit your startup.m file so that Horace is added to the Matlab path whenever you restart. Find your startup.m file, which is usually located somewhere like

::

   C:\Usersx\local\startup.m


This is the Matlab default location. Alternatively you can start a new Matlab session and then type

::

   edit startup


and the correct startup file should be found.

Assuming that you have unpacked herbert into the folder: c:\\mprogs\\Herbert, and the herbert_init.m can be found in this folder, add the to your startup file the following rows:

::

   try
   libisis_off();
   catch
   end
   try
   herbert_off();
   catch
   end


::

   addpath('c:\\mprogs\\Herbert');
   herbert_init;


Installation by editing and registering package_on file
=======================================================

1) Edit the first executable row of the **herbert_on.m.template** file, which can be found in Herebert/admin folder putting there the path where you unpacked Herbert. e.g., if you unpacked Herbert into c:\\mprogs\\Herbert,
write there:

::

   her_default_path='c:/mprogs/Herbert';

2) Rename **herbert_on.m.template** into **herbert_on.m** and move this file into the folder where matlab can always found it.

   a) To do that we recommend creating folder:

      ::

	 mkdir $matlab_folder$/toolbox/ISIS

      where $matlab_folder$ is the folder where matlab is installed (type (bash) **ls -l \`which matlab\`** under Unix or 'right click on matlab icon' and select *properties* under windows and select the path above /bin folder in both cases)

   b) Start matlab and execute:

      ::

	 >>addpath($matlab_folder$/toolbox/ISIS) % replace $matlab_folder$ by real matlab path identified at step 2a)
	 >>savepath()

   c) move herbert_on.m file there and update toolbox cache typing:

      ::

	 >>rehash toolbox

      or selecting this option from the GUI (File->preferences->general->update toolbox cache in Matlab 2011b but can be in different place for different Matlab version)

Herbert becomes available after starting matlab typing ``herbert_on``. Alternatively, you can add herbert_on to your startup file.

Under Uinx-like OS you usually need to be an administrator, to edit /toolbox folder, so any other convenient location, where you have write access can be used instead.


Main Capabilities
=================

Herbert has just been developed and have not had extensive used manual yet. Its main graphics and fitting capabilities are similar to `Libisis <http://www.libisis.org/>`__.


Herbert and Libisis
===================

If both Herbert, and Libisis are present on your system (and you have not disabled Libisis in your startup file as suggested above), Horace will use the package which has been initiated last. There are number of Herbert and Libisis commands, which have the same syntax. The package, initiated last will set up its command to use from Matlab command prompt. Older versions of Libisis are not compatible with Herbert, so it is suggested to download and setup latest Libisis version if you have to use it together with Herbert (in one Matlab session).

We suggest to setup Herbert and Libisis using package_on() approach (libisis_on template file can be found in Libisis/ISIS_utilities folder). This will allow you to switch between Herbert and Libisis typing corresponding package name. Screenshot-Horace_Planner.
