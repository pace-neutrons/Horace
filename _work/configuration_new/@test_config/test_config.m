function this=test_config
% Create the test configuration.
%
%   >> this=test_config
%
% Type >> test_config  to see the list of current configuration option values.

% This is an example illustrating a simple configuration class, with two freely
% alterable fields, and two sealed fields.
%
% Fields are:
%   v1      A user alterable field
%   v2      Another user alterable field
%   v3      A field that cannot be changed, but is visible to display or retrieve
%   v4      Another field that cannot be changed, but is visible to display or retrieve

%--------------------------------------------------------------------------------------------------
%  ***  Alter only the contents of the subfunction at the bottom of this file called     ***
%  ***  default_config, and the help section above, which describes the contents of the  ***
%  ***  configuration structure.                                                         ***
%--------------------------------------------------------------------------------------------------
% This block contains generic code. Do not alter. Alter only the sub-function default_config below

% This block contains generic code. Do not alter. Alter only the sub-function default_config below
root_config=herbert_root_config;

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
%   - if no sealed fields:  ...,sealed_fields,{{''}},...
%   - if one sealed field   ...,sealed_fields,{{'v1'}},...
%   - if two sealed fields  ...,sealed_fields,{{'v1','v2'}},...
%  Note that 'sealed_fields' will be treated as a sealed field, whether or not it is in the list.
%
%--------------------------------------------------------------------------------------------------
function config_data=default_config

config_data=struct(...
    'v1',10000000,...
    'v2',9,...
    'v3','hello',...
    'v4',[13,14],...
    'sealed_fields',{{'v3','v4'}}...
    );
