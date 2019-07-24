function typical_config_settings_helper
% the script used to help generating typical default configurations for all
% known machine types.
%

% store all existing configurations to not to distroy it due to variations
parc = parallel_config;
parc.saveable = false;
parc_c = parc.get_data_to_store();
clob1 = onCleanup(@()set(parc,parc_c));

herc = herbert_config;
herc.saveable = false;
herc_c = herc.get_data_to_store();
clob2 = onCleanup(@()set(herc,herc_c));

horc = hor_config;
horc.saveable = false;
horc_c = horc.get_data_to_store();
clob3 = onCleanup(@()set(horc,horc_c));

hpcc = hpc_config;
hpcc.saveable = false;
hpcc_c = hpcc.get_data_to_store();
clob4 = onCleanup(@()set(hpcc,hpcc_c));
%
cm = opt_config_manager();
% Generic settings:--------------------------------------------------------
parc.parallel_framework ='herbert';
parc.shared_folder_on_local = '';
parc.shared_folder_on_remote = '';
parc.working_directory = '';

herc.force_mex_if_use_mex = false;
herc.log_level = 1;
herc.init_tests = 0;
%
horc.ignore_nan = true;
horc.ignore_inf = false;
horc.delete_tmp = true;
horc.force_mex_if_use_mex = false;

% -------------------------------------------------------------------------
% define optimal configuration for windows small
set_windows_small(parc,herc,horc,hpcc);
% Assume this is windows small and save configuration
cm.this_pc_type = 1;
cm.save_configurations('Typical configuration for Windows small machine assumes no MPI settings and use OMP if possible');

% ouf MAC configuration is very similar to winwos small except it does not
% support mex
%
set_mac_small(parc,herc,horc,hpcc);
cm.this_pc_type = 'a_mac';
cm.save_configurations('Typical configuration for MAC machine assumes no MPI settings and no mex code');

% let's configure Windows large.
set_windows_large(parc,herc,horc,hpcc)
cm.this_pc_type = 2;
cm.save_configurations('Typical configuration for Windows large machine assumes use some MPI use OMP');

% let's configure iDaaaS small
set_idaaas_small(parc,herc,horc,hpcc)
cm.this_pc_type = 'idaaas_small';
cm.save_configurations('iDaaaS small machine should have mex code but would not benefit from MPI');

% iDaaaS large
set_idaaas_large(parc,herc,horc,hpcc)
cm.this_pc_type = 'idaaas_large';
cm.save_configurations('iDaaaS large machine benefit from mex code and can run some MPI');

% Unix small does not have mex code and would not benitif from mpi
set_unix_small(parc,herc,horc,hpcc)
cm.this_pc_type = 'unix_small';
cm.save_configurations('General Unix pc would not have mex code so, user should set it up after compiling it himself');

% Unix large is our isiscompute machine
set_unix_large(parc,herc,horc,hpcc)
cm.this_pc_type = 'unix_large';
cm.save_configurations('Unix large is our isiscompute machine which uses OMP and MPI and everything is present');
%----------------------------------------------------------------------------------------------------------------

function set_windows_small(parc,herc,horc,hpcc)
%
herc.use_mex = true;
herc.use_mex_C = true;
%
horc.mem_chunk_size =  5000000;
horc.threads = 8;
horc.use_mex = true;
%
hpcc.build_sqw_in_parallel = 0;
hpcc.parallel_workers_number =  2;
hpcc.combine_sqw_using = 'mex_code';
hpcc.mex_combine_thread_mode=0;
hpcc.mex_combine_buffer_size=64*1024;
%

function set_mac_small(parc,herc,horc,hpcc)
%
herc.use_mex = false;
herc.use_mex_C = false;

%
horc.mem_chunk_size =  5000000;
horc.use_mex = false;
%
hpcc.build_sqw_in_parallel = 0;
hpcc.parallel_workers_number =  2;
hpcc.combine_sqw_using = 'matlab';
hpcc.mex_combine_thread_mode=0;
hpcc.mex_combine_buffer_size=64*1024;
%
function set_windows_large(parc,herc,horc,hpcc)
%
herc.use_mex = true;
herc.use_mex_C = true;
%
horc.mem_chunk_size =  20000000;
horc.threads = 8;
horc.use_mex = true;
%
hpcc.build_sqw_in_parallel = 1;
hpcc.parallel_workers_number =  4;
hpcc.combine_sqw_using = 'mex_code';
hpcc.mex_combine_thread_mode=0;
hpcc.mex_combine_buffer_size=128*1024;

function set_idaaas_small(parc,herc,horc,hpcc)
%
herc.use_mex = true;
herc.use_mex_C = true;
%
horc.mem_chunk_size =  5000000;
horc.threads = 8;
horc.use_mex = true;
%
hpcc.build_sqw_in_parallel = 0;
hpcc.parallel_workers_number =  2;
hpcc.combine_sqw_using = 'mex_code';
hpcc.mex_combine_thread_mode=1;
hpcc.mex_combine_buffer_size=8*1024;
%
function set_idaaas_large(parc,herc,horc,hpcc)
%
herc.use_mex = true;
herc.use_mex_C = true;
%
horc.mem_chunk_size =  20000000;
horc.threads = 8;
horc.use_mex = true;
%
hpcc.build_sqw_in_parallel = 1;
hpcc.parallel_workers_number =  6;
hpcc.combine_sqw_using = 'mex_code';
hpcc.mex_combine_thread_mode=1;
hpcc.mex_combine_buffer_size=8*1024;



function set_unix_small(parc,herc,horc,hpcc)
%
herc.use_mex = false;
herc.use_mex_C = false;
%
horc.mem_chunk_size =  5000000;
horc.threads = 8;
horc.use_mex = false;
%
hpcc.build_sqw_in_parallel = 0;
hpcc.parallel_workers_number =  2;
hpcc.combine_sqw_using = 'matlab';
hpcc.mex_combine_thread_mode=0;
hpcc.mex_combine_buffer_size=128*1024;



function set_unix_large(parc,herc,horc,hpcc)
%
herc.use_mex = true;
herc.use_mex_C = true;
%
horc.mem_chunk_size = 20000000;
horc.threads = 8;
horc.use_mex = true;
%
hpcc.build_sqw_in_parallel = 1;
hpcc.parallel_workers_number =  8;
hpcc.combine_sqw_using = 'mex_code';
hpcc.mex_combine_thread_mode=1;
hpcc.mex_combine_buffer_size=4*1024;
