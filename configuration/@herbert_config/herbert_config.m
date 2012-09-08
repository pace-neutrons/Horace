function this=herbert_config
% Create the Herbert configuration.
%
%   >> this=herbert_config
%
% Type >> herbert_config  to see the list of current configuration option values.

%--------------------------------------------------------------------------------------------------
%  ***  Alter only the contents of the subfunction at the bottom of this file called     ***
%  ***  default_config, and the help section above, which describes the contents of the  ***
%  ***  configuration structure.                                                         ***
%--------------------------------------------------------------------------------------------------
% This block contains generic code. Do not alter. Alter only the sub-function default_config below
root_config=config;

config_name=mfilename('class');
[ok,this]=is_config_stored(root_config,config_name);
if ~ok
    this=class(struct([]),config_name,root_config);
    build_configuration(this,@default_config,config_name);
end


%--------------------------------------------------------------------------------------------------
%  Alter only the contents of the following subfunction, and the help section of the main function
%
%  This subfunction sets the field names, their defaults, and which ones are sealed against change
%  by the 'set' method.
%
%  The sealed fields must be a cell array of field names, or can be empty. The matlab function
%  struct that can be used has confusing syntax for this purpose: suppose we have fields
%  called 'v1', 'v2', 'v3',...  then we might have:
%   - if no sealed fields:  ...,sealed_fields,{{''}},...  (or simply not set field 'sealed_fields')
%   - if one sealed field   ...,sealed_fields,{{'v1'}},...
%   - if two sealed fields  ...,sealed_fields,{{'v1','v2'}},...
%
%--------------------------------------------------------------------------------------------------
function config_data=default_config

config_data=struct(...
    'use_mex',true,                 ...  % use fortran part of mex code
    'use_mex_C',true,               ...  % use C part of mex code
    'force_mex_if_use_mex',false,   ...  % force using mex (ususlly mex failure causes attempt to use matlab). This is rather for testing mex agains matlab
    'log_level', 1,                 .... % the level to report: -1, do not tell even about an errors (usefull for unit tests) 0 - be quet but report errors, 1 report result of long-lasting operations, 2 
    'init_tests',false,             ...  % add uint test folders to search path (option for Herbert testing)
    'sealed_fields',{{}}            ...
    );
