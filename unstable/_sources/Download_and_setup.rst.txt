.. toctree::
   Download_and_Setup_Troubleshutting

####################
 Download and setup
####################

*********************
 System Requirements
*********************

-  Windows 64-bit, or Linux 64-bit operating system

-  Plenty of free disk space in order to cope with the combined data files (> 30GB)

-  16GB RAM (at the very least). It should run on a machine with 4 or 8Gb memory,
   but this mode has not been tested for a long time. It may be very inconvenient
   to process average experimental results on such a machine.

-  Preferably a recent version of Matlab.
   Horace is not tested on releases of Matlab older than R2018b,
   although we make efforts for it to be compatible with the last 5 years of
   releases.
   If you are forced to use an earlier release and run into a problem,
   please open a ticket on
   `GitHub <https://github.com/pace-neutrons/Horace/issues>`__
   or write e-mail to `Horace support team <mailto:HoraceHelp@stfc.ac.uk>`__ 
   and we will back trying to help you.

**********
 Download
**********

Horace releases for Windows and Linux are available to download on
`GitHub <https://github.com/pace-neutrons/Horace/releases>`__.
These packages contain pre-compiled x64 Mex libraries for each OS.

Everything required to run Horace is within the package,
including `Herbert <https://github.com/pace-neutrons/Herbert>`__.

***************************
 Installation Instructions
***************************

To install Horace you should ideally have the administrative rights. To 
install Horace:

1. Extract the release archive to your preferred location.
2. Open Matlab and set that location as your working directory.
3. Run ``horace_install``. Under  Unix, where Matlab GUI would not always run with root privileges
   go to the package folder and run Matlab from command line: ``>>sudo matlab -nosplash -nodesktop -r horace_install``   
4. Now you can call ``horace_on`` from anywhere to start using Horace.

Optional:

5. Launch Matlab from your home folder or GUI and type ``>>edit startup.m``.
   Add string `horace_on();` to enable Horace for each Matlab startup
   to have Horace available each time you start your Matlab session.
6. If you do not have administrative access, the installation would still be possible,
   and should work as described. You may encounter problems with parallel extensions
   and not be able to initialize Horace if Matlab is launched from a folder different from Matlab's `userpath <https://uk.mathworks.com/help/matlab/ref/userpath.html>`__ folder.
   See :ref:`Troubleshooting <Download_and_Setup_Troubleshutting:Download and Setup Trouble-Shutting>` for the details 
   of the installation process in this situation.

If you installing Horace directly from GitHub repository, clone Herbert and Horace repositories to the folder of your choice in the folders ``Herbert`` and ``Horace`` correspondingly. The ``horace_install`` script to run is located in ``your_folder/Horace/admin`` folder. Horace should work after the script was run but to improve performance of some common Horace operations you may need to build mex files yourself. Currently mex files for Windows are stored in the repository, but this may not always be the case in a future. You will need to build mex files for any other operating system.

**********************
 Horace Configuration
**********************

Horace uses configuration files to store its settings and to turn-up its behaviour and performance.
Horace tries to guess the the best performance for your machine, but you should check if the configuration 
it selected is indeed optimal for you.

You can access the settings using the ``hor_config`` class.

.. code-block:: matlab

   >> hor_config

This will print the current Horace configuration.
Descriptions for each option with suggestion for configuring are given below:

.. code-block:: matlab

   >> hc = hor_config()

   hc =

   hor_config with properties:
      % The buffer size for read/write IO operations in filebased algorithms. 
      % (in Horace pixel units)
      % Set it up to ~20M if you machine has 64Gb or RAM, 1M for 4Gb machine.
      mem_chunk_size: 1000000 % optimal value for 32Gb RAM machine
      % 
      % The number of OMP threads to use in Mex routines. This should be equal to 
      % the number of physical cores on your machine.
      threads: 16
      % Ignore NaN data when making cuts (true or false)
      ignore_nan: 1 Keep it default
      % Ignore Inf data when making cuts (true or false) Keep it default
      ignore_inf: 0
      % The verbosity of informational log messages:
      %  -1 - Display no logging
      %   0 - Display major logging information
      %   1 - Display minor and major logging information
      %   2 - Display all logging messages, including timing information
      log_level: -1
      % Make use of Mex libraries (true or false). Make it true if mex routines are available.
      use_mex: 1
      % Automatically delete temporary files generated by sqw generation (true or false)
      % set it to false, if you building your sqw files using write_nsqw_to_sqw algorithm 
      # (Adwanced Horace usage)
      delete_tmp: 1
      % The directory to place temporary files during sqw generation
      working_directory: 'C:\temp'
      % Throw an error if a Mex library cannot be used (true or false) [debugging option]
      force_mex_if_use_mex: 1
      % Reference to Horace's high performance configuration
      high_perf_config_info: [1×1 hpc_config]

Use the usual Matlab syntax to set configuration values:

.. code-block:: matlab

   hc.(property_name) = value;

******************************************
 High Performance Computing Configuration
******************************************

If your have large machine with multiple several cores, fast hard drive connected to parallel file system and large memory, you may benefit from using Horace's
parallel computing extensions. The memory, necessary to make parallel extensions useful may be estimated as 32Gb per main session 
and 16 per each parallel worker as minimum, so if you want to use 4 parallel processes productively, your machine wound normally 
have 96Gb of RAM.

The ``hpc`` command can be used to enable/disable parallel computing options,
as well as provide suggested settings for the current system.

.. code-block:: matlab

   >> hpc;     % display the suggested configuration based on the current system
   >> hpc on   % enable parallel computing
   >> hpc off  % disable parallel computing


For finer grained control over things like: number of parallel workers,
use of Mex routines and which functions are performed in parallel,
use the ``hpc_config`` class.

.. code-block:: matlab

   >> help hpc_config
