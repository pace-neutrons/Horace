function this=config(varargin)
% Base configuration class inherited by user-modifiable application configurations
%
%   >> this = config

% $Revision$ ($Date$)

config_name=mfilename('class');
config_store(config_name,default_config,default_config);
this=class(struct('ok',{true}),config_name);

%--------------------------------------------------------------------------------------------------
function config_data=default_config

config_data = struct(...
   'config_folder_name','mprogs_config',...
   'config_folder_path','',...
   'sealed_fields',{{'config_folder_name','config_folder_path'}});
config_data.config_folder_path = make_config_folder(config_data.config_folder_name);
