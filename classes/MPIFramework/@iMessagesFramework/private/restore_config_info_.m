function [job_info,config_folder] = restore_config_info_(obj,datapath)
% store configuration data necessary to initiate Herbert/Horace mpi
% job on a remote machine.
%
% job_info -- the data describing the job itself.
%

job_info_file = obj.get_par_config_file_name(datapath);
config_folder = fileparts(job_info_file);

if ~(exist(job_info_file,'file') == 2)
    error('iMESSAGES_FRAMEWORK:invalid_argument',...
        ' Job info file %s does not exist',job_info_file);
end

ld = load(job_info_file);
job_info = ld.info;

