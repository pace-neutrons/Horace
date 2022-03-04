########################
Changing Horace settings
########################

It is possible to alter the default settings of Horace, depending on your personal preferences and/or computer specifications.

hor_config
==========

This is a set of basic configurations for Horace. In order to find out the current (default) settings, type

::

   >> hor_config

   This will return the following information:


       mem_chunk_size: 10000000
		     threads: 8
		  ignore_nan: 1
		  ignore_inf: 0
		   log_level: 1
		     use_mex: 1
		  delete_tmp: 1
	   working_directory: 'C:\\tmp'
	force_mex_if_use_mex: 0
       high_perf_config_info: [11 hpc_config]
		  class_name: 'hor_config'
		    saveable: 1
	    returns_defaults: 0
	       config_folder: 'C:\\Users\\abuts\\AppData\\Roaming\\MathWorks\\MATLAB\\mprogs_config'


To change one of the settings, type, for example;

::
   set(hor_config,'mem_chunk_size',5000000);


or

::
   hc = hor_config;
   hc.mem_chunk_size = 500000;


Below are detailed the meanings of the various options.

- ``mem_chunk_size`` refers to the number of pixels that are read into memory at a time when cutting data from a file. If your system is low on memory, it may be worth reducing this number. If you have a large amount of memory it is not, however, necessarily worth increasing this value much beyond the default setting of 10000000, as it does not result in much of a speed up when cutting.


- ``thread`` is the number of OMP computational threads that can be used by mex code. If you have a multi-core machine you can increase this number to make better use of all / more of your cores, but setting it for more then number of the cores or higher than 8 does not usually improve the code productiovity and may even decrease it.

- ``ignore_nan`` means that any NaNs (not-a-numbers) are ignored (if 1) wherever they occur in Horace. You do not usually need to change this value.

- ``ignore_inf`` means that infinities are (or not) ignored depending on whether this value is set to 1 or 0. . You do not usually need to change this value.


- ``log_level`` is a scalar. The larger it is, the more information Horace prints to the Matlab command window during operations. If it is set to -Inf then almost no information is printed to screen. The most useful are log levels 0, 1 and 2.

- ``use_mex`` can be set to either 0 or 1. If 1, then the mex (i.e. C or FORTRAN) routines are preferentially used for e.g. cutting or sqw files generation. Generally these should be used, as they are faster than the Matlab alternatives. However you can, if you wish, choose not to use the mex files and use the Matlab equivalents instead.

- ``delete_tmp`` is set to either 0 or 1, depending on whether you wish tmp files to be deleted after the creation of an sqw file. If set to 0, the tmp files are not deleted. Generally this should be set to 1, except if you want to use ``write_nsqw_to_sqw`` command.

- ``working_directory`` field defines the location where the tmp files are stored during sqw files generation or advanced cutting procedure. The default of this fieldis equal to output of Matlab *tempdir* command. A first gen_sqw satement will set this value to the folder, where you **spe** or **nxspe** files are stored, but you can set up this value to point to the fast hard drive or parallel file system location.

- ``force_mex_if_use_mex`` option is normally used during debugging. In normal operational mode Horace fail back to Matlab if mex code is failing. If this option set to true, the Horace will fail if mex code does not work propertly.


- ``high_perf_config_info`` provides access to Horace high performance options, relevant for work on high performance servers. This options would be better changed by modifying the high perfomance configuration itself. This configuration is returned by **hpc_config** command.

The options ``class_name, saveable, returns_defaults and config_folder`` are the options for experts.

::

    class_name -- just returns the name of current configuration file
    saveable   -- if true, means that the changes in configuration should be stored in file to be restored at next Horace initialization
    returns_defaults -- if true, allow to explore default configuration options ignoring any changes done to configuration by a user
    config_folder -- point to the location where configuration is stored to restore it from during the next Horace initialization.
