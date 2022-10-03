#####################
Horace Configurations
#####################

The Horace tools use a number of configuration files to manage global settings. This document seeks to outline the
various parameters contained in these configurations.

All configurations have the following parameters:
::

   class_name: 'parallel_config'
   saveable: 1
   returns_defaults: 0
   config_folder: '/home/jacob/.matlab/mprogs_config'

- ``class_name``: is the name of the current configuration.
- ``saveable``: Sets whether any changes to the config will be written to file and restored on next Matlab session.
- ``returns_defaults``: Ignore any user changes and return default configurations and parameters.
- ``config_folder``: Folder where configurations are stored for reloading for new Matlab sessions.

..
   Herbert Config
   ==============

   The Herbert config controls a number of settings

   ::

       herbert_config with properties:

                      use_mex: 1
         force_mex_if_use_mex: 0
                    log_level: 1
                   init_tests: 1
             unit_test_folder: '/home/jacob/PACE/Horace/_test'
                   class_name: 'herbert_config'
                     saveable: 1
             returns_defaults: 0
                config_folder: '/home/jacob/.matlab/mprogs_config'


Horace Config
=============

The Horace config (``hor_config``) manages configuration features of the Horace library functions, such as how functions
handle ``NaN`` and ``inf``, the verbosity of the code and whether to use compiled C++ accelerator codes. It also
contains references to the ``hpc_config`` to manage high-performance functionality.

::

    hor_config with properties:

             mem_chunk_size: 10000000
                 ignore_nan: 1
                 ignore_inf: 0
                  log_level: 1
                    use_mex: 1
                 delete_tmp: 1
          working_directory: '/tmp/'
       force_mex_if_use_mex: 0
      high_perf_config_info: [1x1 hpc_config]
                 class_name: 'hor_config'
                   saveable: 1
           returns_defaults: 0
              config_folder: '/home/jacob/.matlab/mprogs_config'



- ``mem_chunk_size`` : (Advanced) The volume (in bytes) of data to be processed in one operation during cuts.
- ``ignore_nan`` : Whether binning treats ``NaN`` as a value or simply filters the values before computing the new bins.
- ``ignore_inf`` : Whether binning treats ``inf`` as a value or simply filters the values before computing the new bins.
- ``log_level`` :  How verbose the code should be:
  * -1 : No output is produced.
  * 0 : Major notifications are printed.
  * 1 : Minor notifications are printed.
  * 2 : Runs are timed and this information is printed too.
- ``use_mex`` : Whether to use compiled C++ accelerator MEX code to speed up key Horace operations.
- ``force_mex_if_use_mex`` : (Advanced) If MEX fails for whatever reason, fail the calculation instead of falling back to Matlab code.
- ``delete_tmp`` : Whether to automatically delete temporary files after generating SQW files.
- ``working_directory`` : The directory to which temporary files are written
- ``high_perf_config_info`` : Reference to the HPC configuration (see below)


HPC Config
==========

The HPC config contains information relating to using high-performance (MEX and parallel) code. It also contains
references to several higher level features of the ``parallel_config`` as well as a direct reference to the config
itself.

::

    hpc_config with properties:

        build_sqw_in_parallel: 0
            combine_sqw_using: 'matlab'
          combine_sqw_options: {'matlab'  'mex_code'  'mpi_code'}
      mex_combine_thread_mode: 0
      mex_combine_buffer_size: 65536
            parallel_multifit: 0
      parallel_workers_number: 2
             parallel_cluster: 'herbert'
       parallel_configuration: [1x1 parallel_config]
                  hpc_options: {1x5 cell}
                   class_name: 'hpc_config'
                     saveable: 1
             returns_defaults: 0
                config_folder: '/home/jacob/.matlab/mprogs_config'



- ``build_sqw_in_parallel`` : Whether to use parallel algorithms to generate and combine SQW objects
- ``combine_sqw_using`` : Determines the algorithm to use for SQW combination
  - ``matlab`` : this mode uses Matlab code to combine files. Slowest but most reliable method.
  - ``mex_code`` : Uses multi-threaded compiled C++ MEX code to combine files. MEX code needs to be compiled to use.
  - ``mpi_code`` : (Experimental) Uses the MPI Framework to combine files. Needs ``parallel_config`` set up
- ``combine_sqw_options`` : List of the possible options above
- ``mex_combine_thread_mode`` : Threading mode for when ``build_sqw_in_parallel`` is enabled.
  * 0 : one thread reads tmp files and another writes combined information into the target file
  * 1 : one thread writes combined sqw file and two threads are launched for each contributing file to read necessary
  information.
- ``mex_combine_buffer_size``: size of buffer in bytes used by MEX code while combining files per each file.
- ``parallel_multifit``: Enable fitting computation in parallel using the MPI Framework. Needs ``parallel_config`` set
  up.
- ``hpc_options`` : List of these options for use in internal functions.

Mirrors of ``parallel_config`` variables for access, see ``parallel_config`` for more info.
- ``parallel_workers_number``
- ``parallel_cluster``
- ``parallel_configuration``


Parallel Config
===============

The ``parallel_config`` contains information relating to how the parallel cluster is set up along with threading.

::

    parallel_config with properties:

                       worker: 'worker_v2'
                  is_compiled: 0
             parallel_cluster: 'herbert'
               cluster_config: 'local'
      parallel_workers_number: 2
          is_auto_par_threads: 0
                      threads: 8
                  par_threads: 4
               known_clusters: {1x5 cell}
          known_clust_configs: {'local'}
       shared_folder_on_local: ''
      shared_folder_on_remote: ''
            working_directory: '/tmp/'
             wkdir_is_default: 1
             external_mpiexec: ''
               slurm_commands: [0x1 containers.Map]
                      n_cores: 8
                   class_name: 'parallel_config'
                     saveable: 1
             returns_defaults: 0
                config_folder: '/home/jacob/.matlab/mprogs_config'

- ``worker``: (Advanced) Parallel worker script to run on instantiating parallel jobs.
- ``is_compiled``: (Advanced) Whether the above script is a compiled script or a raw matlab script.
- ``parallel_cluster``: Method of parallelism to employ options are:
  * ``herbert`` : Poor man's MPI cluster, single node only. Launches separate Matlab sessions using Java Launcher.  The
  sessions exchange information between each other using file-based messages (.mat files), so this cluster
  is not suitable for any tasks, demanding heavy interprocess communications.
  * ``parpool`` : Uses Matlab parallel computing toolbox to run parallel jobs.  Refer to the parallel toolbox user's
  manual for the description of such clusters.
  * ``mpiexec_mpi`` : Uses C++ wrapped MPI libraries and mpiexec to run parallel jobs. MEX code needs to be compiled to use.
  * ``slurm_mpi`` : Uses C++ wrapped MPI libraries and submits job to Slurm job queues. MEX code needs to be compiled to use.
- ``cluster_config`` : The configuration class describing parallel cluster, defined for each cluster (see :ref:`Parallel`__).
- ``parallel_workers_number`` : Number of parallel jobs to spawn for workers.
- ``is_auto_par_threads`` : Used in internal functions to determine whether ``par_threads`` has been manually set.
- ``threads`` : Number of threads to run C++ threaded jobs with.
- ``par_threads`` : Number of threads to run spawned parallel jobs with.
- ``known_clusters`` : List of available options for ``parallel_cluster``
- ``known_clust_configs`` : List of available options for ``cluster_config``
- ``shared_folder_on_local`` : Folder for file-based messaging for local machine
- ``shared_folder_on_remote`` : Folder for file-based messaging for remote machine (if different)
- ``working_directory`` : Folder where temporary files are written
- ``wkdir_is_default`` : Whether or not the ``working_directory`` has been manually assigned
- ``external_mpiexec`` : Path to ``mpiexec`` or ``mpirun`` program if not default (internal)
- ``slurm_commands`` : Extra command line arguments to be added to Slurm submission jobs (if ``parallel_cluster `` is ``slurm_mpi``)
- ``n_cores`` : Quick readout of Matlab's estimate of number of cores on local machine.
