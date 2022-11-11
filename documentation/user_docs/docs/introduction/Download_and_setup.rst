####################
 Download and setup
####################

*********************
 System Requirements
*********************

-  Either a Windows 64-bit or a Linux 64-bit operating system.

-  Plenty of free disk space (> 30GB) in order to cope with the combined data files.

-  16GB or more of RAM. Horace will just about run on a machine with 4 or 8Gb memory,
   but may be quite slow and may not be able to process newer larger datasets.

-  Preferably a recent version of Matlab.
   Horace is not tested on releases of Matlab older than R2018b.
   However, if you require Horace to run on older versions of Matlab,
   and encounter problems, please open a ticket on
   `GitHub <https://github.com/pace-neutrons/Horace/issues>`__
   or send an e-mail to the `Horace support team <mailto:HoraceHelp@stfc.ac.uk>`__ 
   and we will try to help you.

**********
 Download
**********

Horace releases for supported operating systems are available to download on
`GitHub here <https://github.com/pace-neutrons/Horace/releases>`__.
These packages contain pre-compiled `mex` libraries for each OS.

These released and packaged *Horace distributions* each contain the full 
`Horace <https://github.com/pace-neutrons/Horace>`__
fileset required to run Horace. Each fileset now includes the Herbert support library
functions which were previously distributed as a separate library.

You can also run the latest development version (see below for how to get it); again you no 
longer need to obtain Herbert as a separate download.


***************************
 Installation Instructions
***************************

Standard release
----------------

To install Horace from the release distribution you should ideally have administrative rights. To 
install Horace:

1. Extract the release archive to your preferred location on your file system.
2. Open Matlab and run ```horace install``:

 - Under Windows, open Matlab and change to the ``admin`` folder under the release location. 
   On the Matlab command line run ``horace_install``.
	
 - Under Unix, where the Matlab GUI may not always run with root privileges, from the system 
   shell command line go to the ``admin`` folder under the package folder and open Matlab
   as: ``sudo matlab -nosplash -nodesktop -r horace_install``.

3. In either case you are now in the Matlab GUI environment, and you can call ``horace_on`` from anywhere inside Matlab to start using Horace.

Optionally, to have Horace available each time you start your Matlab session,
you can add ``horace_on`` to your start-up file:

 - Launch Matlab from your home folder or GUI and type ``edit startup.m`` after the ``>>`` prompt in the command line.
 - Add ``horace_on();`` to the end of the file.
 
Without administrative access
-----------------------------
   
If you do not have administrative access, the installation may still be possible,
and should often work as described. However, you may encounter problems with parallel extensions
and not be able to initialize Horace if Matlab is launched from a folder different from Matlab's
`userpath <https://uk.mathworks.com/help/matlab/ref/userpath.html>`__ folder.
See the `Troubleshooting`_ section below for details of the installation process in this situation.

Development versions
--------------------

If you want to install the latest development version of Horace,
you should first *clone* the `Horace <https://github.com/pace-neutrons/Horace>`__ ``git`` repository.
You can then use the ``horace_install`` script in the ``admin`` subfolder of the cloned Horace repository.
Horace should work once the install script has been run, but, to improve performance of some common Horace operations,
in this case you may need to build the `mex` files yourself.
Currently `mex` files for Windows are stored in the repository, but this may not always be the case in future.
You will need to build `mex` files for other operating systems.


**********************
 Horace Configuration
**********************

.. note::

   From this point on in these documents, a line starting ``>>`` in a code block indicates that the text after
   the ``>>`` is a Matlab command to be input on the Matlab command line of the current session.

Horace uses configuration files to store its settings and to tune its behaviour and performance.
Horace tries to guess the best performance for your machine, but you should check if the configuration 
it selects is indeed optimal for you.

You can access the settings using the ``hor_config`` class as follows:

.. code-block:: matlab

   >> hc = hor_config()

This will cause Matlab to output a list of the properties of the ``hor_config`` object; what follows is an
example of such output plus added Matlab comments (starting ``%``) which describe each output.
 
 .. code-block:: matlab

   hc =

   hor_config with properties:
      % The buffer size for read/write IO operations in filebased algorithms. 
      % (in Horace pixel units)
      % Set it up to ~20M if you machine has 64Gb or RAM, 1M for 4Gb machine.
      mem_chunk_size: 1000000 % optimal value for 32Gb RAM machine
      % 
      % The number of OMP threads to use in `mex` routines. This should be equal to 
      % the number of physical cores on your machine.
      threads: 16
      % Ignore NaN data when making cuts (true or false)
      ignore_nan: 1  % (default) 
      % Ignore Inf data when making cuts (true or false)
      ignore_inf: 0  % (default)
      % The verbosity of informational log messages:
      %  -1 - Display no logging
      %   0 - Display major logging information
      %   1 - Display minor and major logging information
      %   2 - Display all logging messages, including timing information
      log_level: -1
      % Make use of `mex` libraries (true or false). Make it true if `mex` routines are available.
      use_mex: 1
      % Automatically delete temporary files generated by sqw generation (true or false)
      % set it to false, if you are building your sqw files using write_nsqw_to_sqw directly
      delete_tmp: 1
      % The directory to place temporary files during sqw generation
      working_directory: 'C:\temp'
      % Throw an error if a `mex` library cannot be used (true or false) [debugging option]
      force_mex_if_use_mex: 1
      % Reference to Horace's high performance configuration
      high_perf_config_info: [1×1 hpc_config]

It also creates a variable ``hc`` from which you can use the usual Matlab syntax to set any configuration values:

.. code-block:: matlab

   hc.(property_name) = value;
   
if you do not need this access, you can omit the ``hc =`` from the call to ``hor_config``; the configuration will 
still be printed.

******************************************
 High Performance Computing Configuration
******************************************

If your have a large machine with multiple cores, a fast hard drive connected to parallel file system and a large memory,
you may benefit from using Horace's parallel computing extensions.
The memory necessary to make parallel extensions useful may be estimated as 32Gb per main session 
and 16Gb per each parallel worker as minimum, so if for example you want to use 4 parallel processes productively,
your machine should have 96Gb of RAM.

The ``hpc`` command can be used to enable/disable parallel computing options,
as well as provide suggested settings for the current system.


.. code-block:: matlab

   >> hpc;      % display the suggested configuration based on the current system
   >> hpc on;   % enable parallel computing
   >> hpc off;  % disable parallel computing

With the terminal ``;`` to suppress printing results, the use of ``hpc`` without an option will give a table like

:: 

	|-------------------------|----------------|----------------|
	| computer hpc options    | current val    | recommended val|
	|-------------------------|----------------|----------------|
	|   build_sqw_in_parallel |              0 |              0 |
	|       combine_sqw_using |       mex_code |       mex_code |
	|-------------------------|----------------|----------------|
	| mex_combine_thread_mode |              0 |              0 |
	| mex_combine_buffer_size |          65536 |          65536 |
	|       parallel_multifit |              0 |              0 |
	|-----------------------------------------------------------|


For finer grained control over things like: number of parallel workers,
use of `mex` routines and which functions are performed in parallel,
use the ``hpc_config`` class.

.. code-block:: matlab

   >> help hpc_config

The ``hpc`` command without the ``;`` terminating also prints the result of running ``hpc_config``:

::

    ans = 

      hpc_config with properties:

          build_sqw_in_parallel: 0
              combine_sqw_using: 'mex_code'
            combine_sqw_options: {'matlab'  'mex_code'  'mpi_code'}
        mex_combine_thread_mode: 0
        mex_combine_buffer_size: 65536
              parallel_multifit: 0
        parallel_workers_number: 2
               parallel_cluster: 'herbert'
         parallel_configuration: [1×1 parallel_config]
                    hpc_options: {1×5 cell}
                     class_name: 'hpc_config'
                       saveable: 0
               returns_defaults: 0
                  config_folder: 'C:\Users\nvl96446\AppData\Roaming\MathWorks\MATLAB\mprogs_config'


*****************
 Troubleshooting
*****************

If you used a `release archive <https://github.com/pace-neutrons/Horace/releases>`__,
then the parent folder to `Horace`  (called ``<extracted_folder>`` below)
will contain ``horace_install`` and this script can be called with no arguments
(it will automatically detect the relevant folders).

The ``horace_install`` installation script then modifies three files:

- `horace_on.m.template <https://github.com/pace-neutrons/Horace/blob/master/admin/horace_on.m.template>`__,
- `herbert_on.m.template <https://github.com/pace-neutrons/Herbert/blob/master/admin/herbert_on.m.template>`__ and
- `worker_v2.m.template <https://github.com/pace-neutrons/Horace/blob/master/admin/worker_v2.m.template>`__

by inserting the location of the `Horace` folder into these files,
and copies them to a folder (``<extracted_folder>/ISIS`` by default) which it adds to the Matlab path
by modifying the global ``pathdef.m`` file. 
This means that all Matlab session including independent parallel workers have access to this path from any location where Matlab has been started.
Unfortunately, this requires administrative (root) privileges.

It is possible to install `Horace` without admin rights, in which case the ``horace_install`` script
will create a ``pathdef.m`` file in the default `userpath` folder (as defined in the
`Matlab documentation for search paths <https://uk.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html>`__).
Some versions of Matlab, however, use different `userpath` folders if they are started as a parallel worker,
which may cause the parallel extensions to fail because they cannot find the ``worker_v2.m`` file, although without reporting any errors.
In these cases, you should run Matlab from the `userpath` folder (e.g. the folder with the ``pathdef.m`` file).

If instead of using the release packages you've cloned the `Horace` repositories from github,
then you should still run ``horace_install`` which is now located in the ``admin`` subfolder of the Horace repository folder.
However, you should now give the exact path to the `Horace` and `Herbert` folders using
the ``horace_root`` and ``herbert_root`` arguments:

.. code-block:: matlab

   cd('horace_folder/admin');
   horace_install('herbert_root', 'path/to/herbert', ...
                  'horace_root', 'path/to/horace', ...
                  'init_folder', 'path/to/horace_on');
				  
.. note::

   Need to ensure that the herbert folder is no longer required.
   
   Need to ensure that the herbert_on template is no longer required.
   
   Need to define and explain the init folder.
