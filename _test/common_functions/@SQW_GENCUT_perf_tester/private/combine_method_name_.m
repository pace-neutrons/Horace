function method = combine_method_name_(~,add_info)
% method returns name constructed from parameters of a tmp-files
% combine method used during sqw file generation.
% Inputs:
% Read hpc config and constructs method name from this config
% Optional:
% addinfo  -- if provided, some additional string, to be
%             appended to the combine name, generated from hpc
%             settings
%
hpc = hpc_config;
method = hpc.combine_sqw_using;
if strcmp(method,'mex_code')
    trm = hpc.mex_combine_thread_mode;
    method = sprintf('%s_MODE%d',method,trm);
elseif strcmp(method,'mpi_code')
    pwn = hpc.parallel_workers_number;
    method = sprintf('%s_nwk%d',method,pwn);
else
    method = sprintf('%s',method);
end
if exist('add_info','var')
    method  = [method,add_info];
end
