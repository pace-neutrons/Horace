function this=test_config
% Retrieve or create the current test configuration
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
persistent this_local;

if isempty(this_local)
    config_name=mfilename('class');

    build_configuration(config,@default_config,config_name);    
    this_local=class(struct([]),config_name,config);
end
this = this_local;


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
    'v1',10000000,...
    'v2',9,...
    'v3','hello',...
    'v4',[13,14],...
    'sealed_fields',{{'sealed_fields','v3','v4'}});
