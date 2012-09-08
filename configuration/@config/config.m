function this=config(varargin)
% Root configuration class inherited by user-modifiable application configurations
%
%   >> this = config
%
% Note of the fields of the root configuration class can be altered. It exists to provide a
% conduit for other configuration classes to use the methods of the root configuration class.

% $Revision$ ($Date$)

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
