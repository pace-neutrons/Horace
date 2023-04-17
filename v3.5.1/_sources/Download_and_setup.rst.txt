##################
Download and setup
##################


System Requirements
===================

- Windows 32-bit, Windows 64-bit, or Linux 64-bit operating system
- Plenty of free disk space in order to cope with the combined data files >30GB
- 8GB RAM (at the very least)
- Preferably a recent version of Matlab. Horace is guaranteed to be supported for Matlab versions for five years earlier than the most recent version. Horace may work with earlier versions, but this is dependent on whether or not newer features of Matlab have been exploited or now-obsolete Matlab functions has been removed.

We have tested Horace on Windows 32-bit and 64-bit operating systems, and Linux 64-bit operating systems. Horace itself is supplied with compiled dll (mex files) for 32 and 64 bit windows. Horace will work with other operating systems (e.g. Mac), albeit slower than if Horace C++ routines have not been compiled. See further down this page for details of how to compile your own mex files.

Download
========

- In order to download or update Horace you must register on the `Horace-announce <http://lists.isis.rl.ac.uk/mailman/listinfo/horace-announce/>`__ mailing list, so that you can be updated with important bug fixes, etc. Your information will not be passed to any third-parties, nor will it be used for anything other than the aforementioned purpose.

- You will then be able to access the `download page <http://horace.isis.rl.ac.uk/kits/>`__

- The download site contains zip files containing the Matlab code (operating system-independent), and pre-compiled Windows 64-bit mex distributions.

- Alternatively, you should be able to build the Horace mex files for your OS (details below) if you have a C++ compiler installed and working with your MATLAB, but feel free to contact `Horace Help <mailto:HoraceHelp@stfc.ac.uk>`__, if you have problems doing that. It will also work out of the box without building any mex files, though the speed of some operations will be 2-5 times slower.

- Recent Horace versions come as standalone distribution pack which includes :ref:`Herbert <Herbert:Herbert>` (see below).

- Full Horace distribution contains Horace Demo and unit tests with the test data, which would allow you comprehensively verify your Horace installation for development purposes. If you are well familiar with Horace and do not need unit tests, you may use `Horace&Herbert_NoDemoNoTests.zip <http://horace.isis.rl.ac.uk/kits/small_downloads/Horace&Herbert_NoDemoNoTests.zip>`__ distribution file from `small downloads <http://horace.isis.rl.ac.uk/kits/small_downloads>`__, which is an order of magnitude slmaller to download.

New Smaller Download
********************

In the download area (see below) you can now get a zipped distribution of Horace **without demo and test files**. This is significantly smaller - about 3MB rather than 100MB for the full installation.

Full Download
*************

Horace uses low level functions, which can be found in :ref:`Herbert <Herbert:Herbert>` package. (e.g. some of the fitting algorithms), so you need Herbert available before installing and using Horace.

- `Horace-announce <http://lists.isis.rl.ac.uk/mailman/listinfo/horace-announce/>`__
- `Download page <http://horace.isis.rl.ac.uk/kits/>`__
- :ref:`Herbert <Herbert:Herbert>`


Standard Installation
=====================

Installation is quite straightforward, since it requires only a small modification to your ``startup.m`` script and for all of the Horace folders to be placed somewhere sensible...

Unzip the contents of the Horace archive into a single directory. You will see two folders **Horace** and **Herbert**, under the top directory of your downloaded archive. The first folder contains Horace itself, and the second one contains low level data access and data manipulation functions. On a Windows machines a good place to put these folders would be somewhere like

::

   C:\\mprogs\\

which is the directory often used for MSlice.

Now you need to edit your ``startup.m`` file so that the Herbert and Horace are added to the Matlab path whenever you restart. Find your ``startup.m`` file, which is usually located somewhere like

::

   C:\\Users\\tgp98\\Documents\\matlab\\startup.m

- in this example the user's login ID is tgp98.

This is the Matlab default location. As an alternative to locating ``startup.m`` as above, you can start a new Matlab session and then type

::

   edit startup

and the correct startup file should be found.

At the bottom of your existing ``startup.m`` file you must put the following:

::

   %----------------------------------------------------------
   % HERBERT:
   try
     herbert_off;
   catch
   end

   addpath('C:\\mprogs\\Herbert\\herbert_core');
   herbert_init;

Next, below the Herbert initialisation, put the following:

::

   %----------------------------------------------------------
   % HORACE:
   try
     horace_off;
   catch
   end
   addpath('C:\\mprogs\\Horace\\horace_core');
   horace_init;

where of course ``C:\\mprogs\\...`` is where we placed the Horace folders. If you put them somewhere else then obviously this bit will be different.

A note of advice -- when you start writing your own Horace functions you may wish to organise them in your own folders. It is strongly recommended that you **do not** put them within the ``C:\\mprogs\\Horace`` directory. When you come to update your Horace installation at some point in the future there is a good chance you will delete your custom functions. Wherever you put your own functions, make sure you add the new directories to the path in your startup file!

The herbert_off and horace_off operations are needed to keep Matlab search path tidy if in the past you had different versions of Herbert or Horace installed.

**VERY IMPORTANT** It is imperative that you **do not** add directories in the Horace main directory to your Matlab path by hand. Such duplication results in very obscure problems, and could, in the worst case scenario, result in your work not having the meaning you thought it did! All of the necessary paths are added, in the correct order, by the ``horace_init`` function in your startup.m script.


Installation with Horace not initialized by default on starting Matlab
======================================================================

You should use the following approach if you do not use Horace each time you start Matlab and want to initiate it only when needed. The following set up is also mandatory if you are going to use Horace high-performance capabilities (see below)

The installation slightly differs depending on the way you obtained Horace. If you downloaded the Horace distribution kit from the Download page (the standard way of obtaining Horace), a file *horace_on.m.template* exists in the root Horace installation directory and you need to modify this file. If you are one of the limited people who can check out Horace and Herbert from the repository, you need to find *horace_on.m.template* and *herbert_on.m.tempate* in the Horace and Herbert admin folders in the root folders and deal with each of these files separately. [For afficionados:*horace_on.m.template* file is actually the merging of *horace_on.m.template* and *herbert_on.m.tempate* from the appropriate admin folders.]

To make an installation you have to rename the **\*.m.template** files to \*.m files, place these files on the `Matlab search path <http://www.mathworks.co.uk/help/techdoc/ref/path.html>`__ and edit the files to point to your Horace and Herbert package locations.

The first row in the **horace_on.m** file should contain the path where you are placed Horace folder and **horace_init.m** file can be found, e.g.:

 default_horace_path ='C:/mprogs/Horace/horace_core';

The second row of the joint **horace_on.m** file or the firest row of the separate **herbert_on.m** file should contain the path, where you placed Herbert folder and **herbert_init.m** file resides, e.g.

 default_herbert_path ='C:/mprogs/Herbert/herbert_core';

To add the initialiation files to Matlab search path on a multi-users Unix server it makes sense to create a special folder in the system area (e.g. */usr/local/mprogs/Users* -- like its done in ISIS) and add this folder to the global Matlab search path, defined in */usr/local/MATLAB/R20XXb/local/toolbox/pathdef.m* file, adding the row **/usr/local/mprogs/Users:**,... to the end or the beginning of the Matlab search path defined there.

If you placed **\*_on.m** files inside Matlab toolbox area (e.g. *$matlab_path$/toolbox/ISIS*), which is in Matlab default search path, you need to rehash toolbox path:

 >> rehash toolbox

If initialization files are placed into some folder and the global *pathdef.m* have not been modified, you need to add folder with initalization files to Matlab path and save the path (e.g. through GUI from main Matlab window *set path->Add Folder -> Save*)

Horace will be available after typing

 >>horace_on()

You can copy contents of **horace_on.m** function into your **startup.m** file and add **horace_on()**; command to the end of the executive part of **startup.m** file instead of the code, described in the previous chapter. **startup.m** file is not executed by Matlab workers so to use high performance capabilities one still needs to modify Matlab search path.

Building mex files
==================

If you have a C++ compiler configured properly with your Matlab, you can obtain the modest speed-ups available in the mex routines. The value of speed-up can be estimated from the table below.
Windows distribution contains all necessary mex files compiled with Visual Studio. The Visual Studio projects are provided togehter with full Horace distribution. Use:

::

   out = check_horace_mex()

command to see if your Horace mex files for Windows work.

This command should return list of versions for all mex files availible for Windows. In this case you can enable using mex files by typing:

::

   hc = hor_config
   hc.use_mex = true;

It the function returns some error, you need to investigate what Windows depencensies are missing on your Windows machine (usually everyting is present). The missing depencencies are normally identified using the `Depencency Walker <https://en.wikipedia.org/wiki/Dependency_Walker>`__.

To enable mex files on a Unix-like machine one should try to execute:

::

   horace_mex()

The command assumes or will request you to select and configure your compiler. See Matlab manuals for the list of supported compilers and how to use the command

::

   mex -setup

and its options.

If you have a modern multicore / multiprocessor machine and have (on Windows), or have successfully compiled, the mex code (on Unix), you should enable OpenMP in the Mex code by enabling number of OpenMP threads in the Horace configuration, which is described in the following chapter.

To compile your code with a modern compiler (gcc version > 4.1) you need to configure your compiler to use OpenMP. The ways of doing that depend on Matlab version you used.
For versions before Matlab 2014a, the compiler is configured in the *mexoptions.sh* file. Matlab versions after 2014a use *mexoptions.xml* flavours.
You need to add the **-fopenmp** option to the C++ and linker keys for your operating system. On Unix machines *mexoptions.sh* (or *mexoptions.xml*) is usually found in the ~/.matlab/R20XXx/ directory, where R20XXx is your version of Matlab e.g. R2012a or R2012b. This file is usually copied to these locations after you have issued the ``mex -setup`` command for your Matlab installation. In addition to enabling **openmp** processing, you need to add list of libraries used by Horace mex code in addition to 3 standard mex libraries, necessary for any mex files to work. To do that you need to modify list of standard mex libraries **-lmx -lmex -lmat** and add **-lut** libraries to it. **ut** is Matlab's utilities library, used by *combine_sqw* and always supplied with Matlab.

The samples of the script files used in ISIS for various Matlab versions are stored in Horace repository under `admin folder <https://github.com/pace-neutrons/Horace/tree/master/admin/compiler_settings>`__.

See `the details <http://shadow.nd.rl.ac.uk/wiki/idr/index.php/Using_Matlab_and_access_to_sample_Matlab_scripts#Configuring_Matlab_2015b_to_work_with_gcc8.4.5_for_combining_using_mex_code_on_RHEL7>`__ of Horace installation on ISIScompute cluster for the ways to modify Matlab 2015b to support C++11 threads. Matlab 2017 natively works with gcc8.4 compiler and does not need such modifications.

Starting from Matlab 2018, Matlab mex script stops using configuration files (It uses it but fully overwrites existing version at compilation time). As the compensation, Matlab *mex* command properly accepts and parses input compiler options. The *horace_mex* compilation script contains all appropriate options for compiling under Unix, so a user does not need to configure a compiler manually.

Horace Configuration and using mex files
========================================

Horace uses configuration files to store its configuration settings, related to compiled mex files and some other computer-dependent options, which provide best Horace performance on various types of computers. Access to Horace configuration is provided through **hor_config** class.

If you are on Windows, or have compiled your code with OpenMP as described above in System Requests you should enable multithreading in the mex code. From the Matlab prompt type:

>>hor_config

This will print the current Horace configuration, which looks like one provided below. Here we provide a general description for each configuration option.

 >>hc=hor_config
 hc =
 hor_config with properties:
 mem_chunk_size: 10000000 -- Maximum number of pixels that are processed at one go during cuts
 threads: 4 -- Number of threads to use in mex files. Should not exceed the number
 of your physical processor cores.
 ignore_nan: 1 -- Ignore NaN data when making cuts
 ignore_inf: 0 -- Ignore Inf data when making cuts
 log_level: 1 -- Set verbosity of informational output:
 -1 No information messages printed
 0 Major information messages printed
 1 Minor information messages printed in addition
 2 Time of the run measured and printed as well.
 use_mex: 1 -- Use mex files for time-consuming operation, if available
 force_mex_if_use_mex: 0 -- testing and debugging option -- Horace will fail if mex can not be used
 delete_tmp: 1 -- automatically delete tmp files after sqw file was generated.
 working_directory: 'c:\\Temp' -- the folder to place tmp files. Matlab tmpdir is default tmp files location directory,
 but if you have not set up this value, gen_sqw will set it up to the place where sqw file
 will be generated. Set it up to a folder on a largest and fastest drive in your system.
 In ISIS this is the folder where your RB folders are located.

Usual Matlab syntax hc.(property_name) = value (e.g. hc.threads = 8) used to change the configuration. Set up this number to the number of physical cores on your machine, but not bigger than 8 as higher numbers provide only very modest improvements to the Horace performance.


Enabling High performance computing extensions
==============================================

If you have a powerful computer with large number of processing cores and have access to a parallel file system or fast bandwidth server disk system attached to you computer, you will benefit from using high performance computing extensions, provided with Horace. To enable these extensions, you need to perform `"Installation with Horace not initialized by default as above" <http://horace.isis.rl.ac.uk/Download_and_setup#Installation_with_Horace_not_initialized_by_default_on_starting_Matlab>`__
Auxiliary command

 >>hpc

shows recommendations on using various high-performance extensions derived from our limited experience with different computers (see below).
Switches **on/off** provided with this command allow to set up all high performance computing options together according to the values from tables, provided below. Our experience with different computer systems is far from extensive, so you will probably need to fine-tune high performance computing extensions to get maximal performance on your system.
The high performance extensions settings are interfaced by **hpc_config** class, accessible by

 >>hpc_config

command.


Enabling multi-sessions processing
**********************************

You can generate tmp files, used during sqw files creation using multiple Matlab workers.

To do that, you need to place *worker_v2.m* script in the location, where Matlab can always find it. The recommended place would be place where **horace.on** command is located.
The **worker_v2.m.template** file can be found in *Herbert/admin* folder. Rename it to **worker_v2.m** and move somewhere to existing data search path. Then you can type:

 >>hc=hpc_config

change:

 >>hc.accum_in_separate_process=true

and select number of separate workers to generate or accumulate sqw files. (See `sqw files generation <http://horace.isis.rl.ac.uk/Generating_SQW_files>`__ for the description of this operation)

Horace contains primitive multi-session framework, which will divide the list of input spe or nxspe files between chosen number of workers and process each sub-list on a separate Matlab session. This operation is beneficial only if you have enough processors and memory to run chosen number of Matlab sessions as if multiple sessions start competing for resources, the processing would actually take longer. Due to experimental status of the framework user is advised to well familiarize himself with single-session way of producing sqw files before embarking on multi-session processing even if his computer benefits from the multi-sessions. As a guideline on setting number of workers, one can look at the table below, measured while processing 231 nxspe files occupying 142Gb in total. The processing involves loading a file (~311Mb) in memory, do some moderately intensive calculations necessary to produce sqw files, and saving approximately 700Mb of results per file back to HDD.

======================================================== ================= ====================== ============ ================== ========== ========== ========== ==========
Computer & OS:                                                                                    Time (min, less is better) to process data using Maltab workers:
------------------------------------------------------------------------------------------------- ---------------------------------------------------------------------------
OS; Processor; RAM; CPU;                                 mex code&compiled OMP threads            main session 1 external session 2 sessions 3 sessions 4 sessions 8 sessions
RHEL7; Xeon E5-4657L&2.5GHz;512Gb; 96cpu(4n)\ :sup:`1)`  nomex             Matlab2015b\ :sup:`2)` 58           55                 32         23         18         12
------||------                                           mex: GCC 4.8      1                      31           22                 12         8          6          5
------||------                                           mex: GCC 4.8      8                      21           24                 11         8          6          4
CentOS7; Xeon X5650&2.67GHz;48Gb; 12(24)\ :sup:`3)`\ cpu nomex             Matlab 2015b           41           43                 26         20         18         18
------||------                                           mex: GCC 4.8      1                      27           22                 17         15         11         12
------||------                                           mex: GCC 4.8      8                      16           18                 14         13         13         11
Windows7\ :sup:`4)`; Xeon X5650&2.67GHz;48Gb; 12(24)cpu; nomex             Matlab 2015b           63           65                 62         55         60         63
------||------                                           mex: VS2015       1                      60           64                 55         61         56         64
------||------                                           mex: VS2015       8                      57           57                 54         55         58         69
OS X El Capitan; i7-2600&3.40GHz; 16Gb; 4(8)cpu;         nomex             Matlab2015b            71           74                 54         45         64         185
======================================================== ================= ====================== ============ ================== ========== ========== ========== ==========

Notes:
 :sup:`1)`\ Combined into 4 PCNUMA nodes
:sup:`2)`\ Matlab after 2014 deploys its own OMP framework, so operations on arrays are performed in parallel.
 Number of threads deployed in this case is controlled by Matlab.
 :sup:`3)`\ CPU number in brackets refers to virtual Intel cpu (threads)
 :sup:`4)`\ Windows does not work well with large files. For this reason, the task appears to be mainly
 file-IO speed constrained, so no much difference in various processing modes can be observed.


Using mex to combine sqw
************************

One of mex files build using horace_mex, namely *combine_sqw* useful mainly on large computers with enhanced IO capabilities. This is why its usage not controlled by **use_mex** key-word of *hor_config* class, but rather by separate **use_mex_for_combine** key-word of *hpc_combine* class (see below). It also uses threading rather then OMP, so its deployment with non-default Matlab compilers may require `special changes to the system <http://shadow.nd.rl.ac.uk/wiki/idr/index.php/Using_Matlab_and_access_to_sample_Matlab_scripts#Configuring_Matlab_2015b_to_work_with_gcc8.4.5_for_combining_using_mex_code_on_RHEL7>`__.

Possible benefits or disadvantages of using mex files to combine sqw are illustrated by the following table:

================================================================================== ====================== =========================== ==================== ==========================
Computer & OS and mex/nomex options:                                                                                                  Performance and Time (min)
------------------------------------------------------------------------------------------------------------------------------------- -----------------------------------------------
Computer and IO system;                                                            mex/nomex mode         IO buffer (in uint64 words) Combining speed Mb/s Time to combine 142Gb file
RHEL7; 512Gb; 96cpu; `CEPHs <https://en.wikipedia.org/wiki/Ceph_%28software%29>`__ Matlab2015b IO         Matlab's internal           67                   37
------||------                                                                     mex, mode 1\ :sup:`1)` 1024                        577                  4
------||------                                                                     mex, mode 0\ :sup:`2)` 1024                        517                  5
------||------                                                                     mex, mode 0            1024*64                     230                  11
CentOS7; 48Gb; 12(24)cpu; `SCSI <https://en.wikipedia.org/wiki/SCSI>`__            Matlab2015b IO         Matlab's internal           55                   45
------||------                                                                     mex, mode 0            1024                        35                   72
------||------                                                                     mex, mode 0            1024*64                     69                   36
------||------                                                                     mex, mode 1            1024*64                     28                   88
Windows7; 48Gb; 12(24)cpu; `SCSI <https://en.wikipedia.org/wiki/SCSI>`__           Matlab2015b IO         Matlab's internal           29                   87
------||------                                                                     mex, mode 1            1024                        12                   214
------||------                                                                     mex, mode 0            1024*64                     21                   121
------||------                                                                     mex, mode 1            1024*64                     6                    412
================================================================================== ====================== =========================== ==================== ==========================

Notes:
 :sup:`1)`\ mode 1 -- each input file (241 tested) has its own thread to read data and separate thread to write combined results to target file.
 :sup:`2)`\ mode 0 -- One thread reads data from input files (241 tested) and another one writes results to the output.
