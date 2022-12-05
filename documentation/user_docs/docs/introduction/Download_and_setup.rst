####################
 Download and setup
####################

*********************
 System Requirements
*********************

-  Windows 64-bit, or Linux 64-bit operating system

-  Plenty of free disk space in order to cope with the combined data files (> 30GB)

-  16GB RAM or more. Horace will run on a machine with 4 or 8Gb memory,
   but may be quite slow and may not be able to process newer larger datasets.

-  Preferably a recent version of Matlab.
   Horace is not tested on releases of Matlab older than R2018b.
   However, if you require Horace to run on older versions of Matlab,
   and encounter problems, please open a ticket on
   `GitHub <https://github.com/pace-neutrons/Horace/issues>`__
   or write an e-mail to `Horace support team <mailto:HoraceHelp@stfc.ac.uk>`__
   and we will try to help you.

**********
 Download
**********

Horace releases for supported operating systems are available to download on
`GitHub here <https://github.com/pace-neutrons/Horace/releases>`__.
These packages contain pre-compiled `mex` libraries for each OS.

***************************
 Installation Instructions
***************************

Standard Matlab install
-----------------------

To install Horace you should ideally have the administrative rights. To
install Horace:

1. Extract the release archive to your preferred location.
2. Open Matlab and change to the ``admin`` folder under that location.
3. Run ``horace_install``.
   Under Unix, where Matlab GUI may not always run with root privileges
   go to the ``admin`` folder under the package folder and run Matlab
   from the command line as: ``sudo matlab -nosplash -nodesktop -r horace_install``
4. Now you can call ``horace_on`` from anywhere to start using Horace.

Optional:

5. To have Horace available each time you start your Matlab session,
   you can add ``horace_on`` to your start-up file:
   Launch Matlab from your home folder or GUI and type ``>> edit startup.m``.
   Then add ``horace_on();`` to the end of the file.

If you do not have administrative access, the installation should still be possible, and should work as described. You
may encounter problems with parallel extensions and may not be able to initialize Horace if Matlab is launched from a
folder different from Matlab's `userpath <https://uk.mathworks.com/help/matlab/ref/userpath.html>`__ folder.  See the
`Troubleshooting`_ section below for details of the installation process in this situation.

Installing the latest version
-----------------------------

If you want to install the latest development version of Horace, you should first ``git clone`` the `Horace
<https://github.com/pace-neutrons/Horace>`__ ``git`` repository. You can then follow the ``horace_install`` procedure as
described above, giving it the path to where `Horace` was cloned.

Horace should work after the install script is run but to improve performance of some common Horace operations, you may
need to build the ``mex`` files yourself.  Currently ``mex`` files for Windows are stored in the repository, but this may
not always be the case in future.  You will need to build ``mex`` files for other operating systems.

**N.B.** In order to build ``mex`` files, it is necessary to have an up to date C++ compiler such as Visual Studio or
the GNU Compiler Collection (GCC).


CMake install
-------------

If you have cloned the repository and have the ``CMake`` tool installed, the Horace package supports a CMake build (1a),
which also builds the relevant `mex` files and links against them.

Horace also ships with a number of install scripts in ``tools\build_config``. These can be used to automate
installation (1b). **N.B.** These equate to installs using CMake wtih preconfigured options.

To install using CMake:


1a. From your console of choice, navigate to the Horace root folder and run:

   ::

      cmake --build build --config Release

1b. From your console of choice navigate to ``tools\build_config`` and run:

   Windows:


   ::

      build.ps1 -build

   Linux:

   ::

      build.sh -build

2. In a Matlab session add the ``<Horace_dir>\build\local_init\`` folder to the `Matlab path <https://www.mathworks.com/help/matlab/ref/addpath.html>`__ and run ``horace_on`` as above.

Optional:

3. To have Horace available each time you start your Matlab session,
   you can add ``horace_on`` to your start-up file:
   a. Launch Matlab
   b. Run ``edit startup.m``.
   c. Then add ``horace_on();`` to the end of the file.

**********************
 Horace Configuration
**********************

Horace uses :ref:`configuration files <manual/Changing_Horace_settings:Changing Horace settings>` to store its settings and to tune its behaviour
and performance.  Horace tries to guess the best performance for your machine, but you should check if the configuration
it selects is indeed optimal for you.

You can access the settings using the ``hor_config`` class.

.. code-block:: matlab

   >> hor_config

This will print the current Horace configuration.
Descriptions for each option with suggestions for configuring are given below:

.. code-block:: matlab

   >> hc = hor_config()

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

Use the usual Matlab syntax to set configuration values:

.. code-block:: matlab

   hc.(property_name) = value;

******************************************
 High Performance Computing Configuration
******************************************

If you have a large task and a machine with multiple cores, you may benefit from using Horace's parallel computing
extensions (see :ref:`manual/Parallel:Running Horace in Parallel`).

The ``hpc`` command can be used to enable/disable parallel computing options,
as well as provide suggested settings for the current system.

.. code-block:: matlab

   >> hpc;     % display the suggested configuration based on the current system
   >> hpc on   % enable parallel computing
   >> hpc off  % disable parallel computing


For finer grained control over things like: number of parallel workers,
use of `mex` routines and which functions are performed in parallel,
use the ``hpc_config`` class.

.. code-block:: matlab

   >> help hpc_config


***************
Troubleshooting
***************

If you used a `release archive <https://github.com/pace-neutrons/Horace/releases>`__, then `Horace` will be in a folder
(called ``<extracted_folder>`` below) with ``horace_install`` and this script can be called with no arguments (it will
automatically detect the folders).

The ``horace_install`` installation script then modifies two files:

- `horace_on.m.template <https://github.com/pace-neutrons/Horace/blob/master/admin/horace_on.m.template>`__,
- `worker_v2.m.template <https://github.com/pace-neutrons/Horace/blob/master/admin/worker_v2.m.template>`__

by inserting the location of the `Horace` folders into these files, and copies them to a folder
(``<extracted_folder>/ISIS`` by default) which it adds to the Matlab path by modifying the global ``pathdef.m`` file.
This means that all Matlab session including independent parallel workers have access to this path from any location
where Matlab has been started.  Unfortunately, this requires administrative (root) privileges.

It is possible to install `Horace` without admin rights, in which case the ``horace_install`` script will create a
``pathdef.m`` file in the default `userpath` folder (as defined in the `Matlab documentation for search paths
<https://uk.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html>`__).  Some versions of Matlab,
however, use different `userpath` folders if they are started as a parallel worker, which may lead the parallel
extensions to fail because they cannot find the ``worker_v2.m`` file, but not to report any errors.  In these cases, you
should run Matlab from the `userpath` folder (e.g. the folder with the ``pathdef.m`` file).

If instead of using the release packages you've cloned the `Horace` repository, then you should still run
``horace_install`` which is located in the ``admin`` subfolder of the Horace repository folder.  However, you should now
give the path to the `Horace` folders using the ``horace_root`` and ``herbert_root`` arguments:

.. code-block:: matlab

   cd('horace_folder/admin');
   horace_install('herbert_root', 'path/to/herbert', ...
                  'horace_root', 'path/to/horace', ...
                  'init_folder', 'path/to/horace_on');
