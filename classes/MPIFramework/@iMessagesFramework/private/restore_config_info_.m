function [job_info,job_info_folder] = restore_config_info_(obj,datapath,varargin)
% store configuration data necessary to initiate Herbert/Horace mpi
% job on a remote machine.
%
% job_info -- the data describing the job itself.
%
options = {'-keep_job_info'};
[ok,mess,keep_job_info] = parse_char_options(varargin,options);
if ~ok
    error('iMESSAGES_FRAMEWORK:invalid_argument',mess)    
end

[job_info_file,job_info_folder] = obj.par_config_file(datapath);
job_info_full_file = fullfile(job_info_folder,job_info_file);

if ~(exist(job_info_full_file ,'file') == 2)
    error('iMESSAGES_FRAMEWORK:invalid_argument',...
        ' Job info file %s does not exist in %s folder',...
        job_info_file,job_info_folder);
end

ld = load(job_info_full_file);
job_info = ld.info;
if ~keep_job_info
    delete(job_info_full_file);
end

