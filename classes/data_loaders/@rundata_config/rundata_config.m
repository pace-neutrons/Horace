function this=rundata_config
% Create the Herbert configuration.
%
%   >> this=herbert_config
%
% Type >> herbert_config  to see the list of current configuration option values.
% Defines default values for some rundata variables and other configurations for rundata class

%--------------------------------------------------------------------------------------------------
%  ***  Alter only the contents of the subfunction at the bottom of this file called     ***
%  ***  default_config, and the help section above, which describes the contents of the  ***
%  ***  configuration structure.                                                         ***
%--------------------------------------------------------------------------------------------------
% This block contains generic code. Do not alter. Alter only the sub-function default_config below

config_name=mfilename('class');
build_configuration(config,@default_config,config_name);    
this=class(struct([]),config_name,config);


%--------------------------------------------------------------------------------------------------
%  Alter only the contents of the following subfunction, and the help section of the main function
%
%  This subfunction sets the field names, their defaults, and which ones are sealed against change
%  by the 'set' method.
%
%  The sealed fields must be a cell array of field names, or can be empty. The matlab function
%  struct that can be used has confusing syntax for this purpose: suppose we have fields
%  called 'v1', 'v2', 'v3',...  then we might have:
%   - if no sealed fields:  ...,sealed_fields,{{''}},...
%   - if one sealed field   ...,sealed_fields,{{'v1'}},...
%   - if two sealed fields  ...,sealed_fields,{{'v1','v2'}},...
%
%--------------------------------------------------------------------------------------------------
function config_data=default_config

config_data=struct(...
    'is_crystal',true, ...
    'omega',0,...
	'dpsi', 0,...
	'gl',   0,...
	'gs',   0,...
    'sqw_ext','.tmp',... % the extension an sqw file generated from a runfile would have
    'sqw_path','',...    % the path to write temporary sqw files. Default -- the sama as initial sqw file. 
    'sealed_fields',{{}} ...
    );
