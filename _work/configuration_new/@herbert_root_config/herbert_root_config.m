function this=herbert_root_config(varargin)
% Base configuration class inherited by user-modifiable application configurations
%
%   >> this = config

% $Revision: 128 $ ($Date: 2012-01-23 08:30:12 +0000 (Mon, 23 Jan 2012) $)

[ok,this]=config_store;
if ~ok
    config_name=mfilename('class');
    this=class(struct('ok',{true}),config_name);
    config_store(config_name,default_config(),default_config(),this)
end


%--------------------------------------------------------------------------------------------------
function config_data=default_config

config_data = struct(...
   'config_folder_name','mprogs_config',...
   'config_folder_path','',...
   'sealed_fields',{{'config_folder_name','config_folder_path'}});
config_data.config_folder_path = make_config_folder(config_data.config_folder_name);
