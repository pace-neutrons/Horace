###############################
Horace and Libisis installation
###############################


THIS PAGE IS UNDER CONSTRUCTION
*******************************

- `Libisis <http://www.libisis.org/>`__

Unzip all of the Horace folders into a single directory. The directory structure below this will be taken care of by your zip program. On a Windows machines a good place to put this would be somewhere like

::

   C:\mprogs\

which is the directory often used for MSlice. You'll notice that inside the directory structure there are lots of *p-files* in addition to *m-files*. The p-files are compiled versions of the Matlab code, and therefore cannot be viewed or edited. However they work just as the m-files would, and are called by Matlab in the same way.

Now you need to edit your ``startup.m`` file so that Horace is added to the Matlab path whenever you restart. Find your ``startup.m`` file, which is usually located somewhere like

::

   C:\MATLAB\R2008a\toolbox\local\startup.m



This is the Matlab default location. Alternatively you can start a new Matlab session and then type

::

   edit startup


and the correct startup file should be found.

At the bottom of your existing ``startup.m`` file you must put the following:

::

   %----------------------------------------------------------
   % HERBERT:
   try
     libisis_off;
   catch
   end
   try
     herbert_off;
   catch
   end

   addpath('C:\mprogs\Herbert\');
   herbert_init;


Next, below the Libisis or Herbert initialisation, put the following:

::

   %----------------------------------------------------------
   % HORACE:
   try
     horace_off;
   catch
   end
   addpath('C:\mprogs\Horace');
   horace_init;


where of course ``C:\\mprogs\\...`` is where we placed the Horace folders. If you put them somewhere else then obviously this bit will be different.

A note of advice -- when you start writing your own Horace functions you may wish to organise them in folders within the ``C:\\mprogs\\Horace\\functions\\`` directory. If you do this then make sure you add the new directories to the path in your startup file!

The libisis_off and horace_off operations are needed to keep Matlab search path tidy if in the past you had different versions of Libisis or Horace installed.

**VERY IMPORTANT** It is imperative that you **do not** add directories in the Horace main directory to your Matlab path by hand. Such duplication results in very obscure problems, and could, in the worst case scenario, result in your work not having the meaning you thought it did! All of the necessary paths are added, in the correct order, by the ``horace_init`` function in your startup.m script.

----------------------------

If you intend to use, or already have, Libisis for operations, you have to initiate Libisis first. When you download Libisis from the `Libisis website <http://www.libisis.org/>`__ the version you get will always be the latest version. Also note that this example assumes that you downloaded the Libisis software into the ``C:/mprogs/`` directory.

To initiate Libisis, at the bottom of your existing ``startup.m`` file you must put the following:

::

   %----------------------------------------------------------
   % LIBISIS:
   try
     libisis_off;
   catch
   end
   try
     herbert_off;
   catch
   end

   addpath('C:\mprogs\\libisis\');
   libisis_init;


Supporting package (Herbert or Libisis) will be the package, initiated last. If nothing was initiated, horace_on will try to use Herbert and Libisis if Herbert fails.


Installation using package_on file
==================================

If you installed :ref:`Herbert <manual/Herbert:Herbert>` or Libisis editing **package_on** file, (see, e.g. `Installing Herbert using herbert_on file <http://horace.isis.rl.ac.uk/Herbert#Installation_by_editing_and_registering_package_on_file>`__) you can install horace using **horace_on** file too. If you have in your system both Libisis and Herbert and want to use both packages, you should probably adopt initiating the packages using package_on approach (where package can be herbert, libisis or horace).

The **horace_on.m.template** can be found in *Horace/admin* folder. As before, edit this template, replacing first row with the path where you are installing Horace and **horace_init.m** file can be found, e.g.:

 default_horace_path ='C:/mprogs/Horace';

Then rename this file into **horace_on.m** and move it to the place, where you have already placed herbert_on and/or libisis_on files

Supporting package (Herbert or Libisis) will be the package, initiated last. If nothing was initiated, horace_on will try to use Herbert and Libisis if Herbert fails. Scan_figure.
