###################################
Download and Setup Trouble-Shutting
###################################

Installation process modifies three files, namely `horace_on.m.template <https://github.com/pace-neutrons/Horace/blob/master/admin/horace_on.m.template>`__, 
`herbert_on.m.template <https://github.com/pace-neutrons/Herbert/blob/master/admin/herbert_on.m.template>`__ and `worker_v2.m.template <https://github.com/pace-neutrons/Horace/blob/master/admin/worker_v2.m.template>`__ by renaming them to ``horace_on.m``, ``herbert_on.m`` and ``worker_v2.m`` and inserting the location of the Horace and Herbert packages (``package installation folder`` -- the place where you have unpacked these packages) into these files. ``herbert_on`` and ``horace_on`` files contain the scripts, used to initialize Herbert and Horace correspondingly. ``horace_on`` also executes ``herbert_on`` if ``herbert_on`` has not been executed earlier. ``worker_v2`` script is used by Horace parallel extensions to initialize Horace from independent parallel workers communicating over MPI. 

After initialization, the installation script copies modified ``horace_on.m`` ``hebert_on`` and ``worker_v2.m`` files to ``package installation folder/ISIS`` folder, and adds the ``package installation folder/ISIS`` folder to the `Matlab search path <https://uk.mathworks.com/help/matlab/matlab_env/what-is-the-matlab-search-path.html>`__, defined by ``pathdef.m`` file. The ``pathdef.m`` is normally located in **$MATLABROOT/toolbox/local** directory. If you run the installation script under administrative account, the original `pathdef.m` file is modified and all Matlab session including independent parallel workers have access to this path from any location where Matlab has been started.

If you do not have write access to the `pathdef.m` file, the script stores modified copy of the file in the Matlab **$USERPATH** directory. This directory is available and inserted in the beginning Matlab search path modifying Matlab default search path if you start your Matlab session from the link in the OS GUI or from this directory. Some versions of Matlab would not use the same **$USERPATH** directory if you start main Matlab or Matlab parallel workers from other location. This may make ``horace_on`` and ``worker_v2`` scripts not available. Parallel extensions in this case do not report any errors, but would not work. To avoid difficult to identify errors, always modify original `pathdef.m` file, i.e. run Horace installation with administrative access.



