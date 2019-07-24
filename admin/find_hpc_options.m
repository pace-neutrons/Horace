function varargout =find_hpc_options(hpc_options_names,varargin)
% method calls opt_config_manager to retrieve a hpc configuration, assumed
% optiomal for this type of computer.
%
% if the option '-set_config' is provided, this configuration is also
% applied to the cofiguration classes. 
%
% Optional outputs are values for hpc_config parameters:
%
% 'combine_sqw_using','mex_combine_thread_mode','mex_combine_buffer_size',
% 'build_sqw_in_parallel','parallel_workers_number'. 
%
% See hpc_config class to get meaning for these options.
%

ocp = opt_config_manager();
% load configuration, assumed optimal for calculated type of the computer.
config = ocp.load_configuration(varargin{:}); 
hpc_cfg = config.hpc_config;

for i=1:nargout
    varargout{i} = hpc_cfg.(hpc_options_names{i});
end