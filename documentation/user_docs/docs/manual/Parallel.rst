##########################
Running Horace in Parallel
##########################


Controlling MPI
===============

Certain operations in Horace are parallelised with an MPI algorithm. These can be enabled in one go using:

::

   hpc('on')

Alternatively different parallel components can be enabled/disabled separately through ``hpc_config``

::

     hpc_config with properties:

         build_sqw_in_parallel: 0
       parallel_workers_number: 2
             combine_sqw_using: 'matlab'
           combine_sqw_options: {'matlab'  'mex_code'  'mpi_code'}
       mex_combine_thread_mode: 0
       mex_combine_buffer_size: 131072
             parallel_multifit: 0
              parallel_cluster: 'herbert'
        parallel_configuration: [1x1 parallel_config]
                   hpc_options: {1x6 cell}
                    class_name: 'hpc_config'
                      saveable: 1
              returns_defaults: 0
                 config_folder: '/home/jacob/.matlab/mprogs_config'

In particular, the parallel enabling options are:

- ``parallel_multifit`` : Enable parallel fitting for ``multifit`` and ``tobyfit``
- ``build_sqw_in_parallel`` : Enable building sqw objects in parallel, i.e. ``gen_sqw``, ``combine_sqw``

The ``parallel_config`` contains most of the information to manage parallelism, though some is stored in ``hpc_config``
(described above):

::

      parallel_config with properties:

                         worker: 'worker_v2'
                    is_compiled: 0
               parallel_cluster: 'herbert'
                 cluster_config: 'local'
                 known_clusters: {'herbert'  'parpool'  'mpiexec_mpi'  'slurm_mpi'  'dummy'}
            known_clust_configs: {'local'}
         shared_folder_on_local: ''
        shared_folder_on_remote: ''
              working_directory: '/tmp/'
               wkdir_is_default: 1
               external_mpiexec: ''
                     class_name: 'parallel_config'
                       saveable: 1
               returns_defaults: 0
                  config_folder: '/home/jacob/.matlab/mprogs_config'

MPI Schemes
===========

Horace can be run in parallel with a number of different schemes, all controlled through the ``parallel_config``.

The five currently implemented parallel schemes are:

1. ``herbert`` (Poor-man's MPI) - Data messages are sent through files written to the hard drive and read by each
process. This is the slowest MPI scheme, but also the one with the fewest requirements.

2. ``parpool`` (Matlab Parallel Toolbox MPI) - Parpool uses Matlab's parallel toolbox parallelism to send messages and
therefore requires the parallel toolbox to be used.

3. ``mpiexec_mpi`` (C++ MPI) - Data messages are sent using C++ wrapping OpenMPI. This requires the MEX files to be
built in order to be used.

4. ``slurm_mpi`` (Slurm MPI) - Data messages are sent using C++ wrapping OpenMPI, but are submitted to a running Slurm
instance by Horace upon starting the job. This requires the MEX files to be built in order to be used.

5. ``dummy`` (Dummy MPI) - Dummy MPI is not MPI, but simply a dummy system for debugging and testing MPI algorithms on
one process in serial.

Managing parallel jobs
======================

Running jobs in parallel is as simple as selecting the appropriate MPI scheme, setting an appropriate
``parallel_workers_number`` and enabling the appropriate flags through the ``hpc_config`` and ``parallel_config``.

**N.B.** Be aware that for small jobs or some combinations of parameters, parallel calculation may, in fact, be slower
than serial execution due to startup times and message sending. In future we hope to bring these times down and
efficiencies up.

Slurm Jobs
==========

When running on Slurm-managed clusters, it is possible to automatically submit jobs to the Slurm queue to be run in
parallel across the cluster. This will attempt to request the number of nodes required to run the selected number of
parallel workers and associated threads, however, if you are using a cluster which requires non-standard options such as
billing accounts and or non-default queues specifying, it is possible to issue extra commands through the
``slurm_commands`` variable accessible via the ``parallel_config`` object. This is a ``containers.Map`` object, and will
only store the latest set commands.

::

   new_commands = containers.Map({'-A' '-p'}, {'account' 'partition'});
   pc = parallel_config();
   pc.slurm_commands = [];                                       % Delete existing Slurm commands
   pc.slurm_commands = new_commands;                             % Set new map
   pc.slurm_commands = '-A account -p=partition'                 % Set as char
   pc.slurm_commands = {'-A' 'account' '-p' 'partition'}         % Set as cellstr of commands (must be in pairs)
   pc.slurm_commands = {{'-A' 'account'} {'-p' 'partition'}}     % Set as cell array of pairs of commands
   pc.update_slurm_commands('-A account -p=partition', false)    % Using update_slurm_commands setting append to false
   pc.update_slurm_commands(new_commands)                        % Using update_slurm_commands omitting append

**N.B.** Setting ``slurm_commands`` by any of the above methods will remove all existing ``slurm_commands`` and set the new ones.

::

   pc.slurm_commands('-A') = 'account'; pc.slurm_commands('-p') = 'partition'            % Set through Map interface
   pc.update_slurm_commands('-A account -p=partition', true);                            % Set through update_slurm_commands
   pc.update_slurm_commands(containers.Map({'-A' '-p'}, {'account', 'partition'}), true)

**N.B.** Setting ``slurm_commands`` by any of the above methods will simply overwrite any existing ``slurm_commands``.

It is possible to set the ``slurm_commands`` variable by loading the appropriate commands from a file if that is what
your cluster team provides. This is done by using the following command:

::

   pc = parallel_config();
   pc = pc.load_slurm_commands_from_file(<filename>, <append>);

Where ``filename`` is the path of the file to load the commands from, and ``append`` specifies whether the commands are
meant to be added to the existing commands or replace them entirely.
