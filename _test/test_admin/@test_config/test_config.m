function this=test_config
% Create the test configuration.
%
%   >> this=test_config
%
% Type >> test_config  to see the list of current configuration option values.
%
% This is an example illustrating a simple configuration class, with two freely
% alterable fields, and two sealed fields.
%
% Fields are:
%   v1      A user alterable field
%   v2      Another user alterable field

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
%  This subfunction sets the field names, their defaults, and which, if any, are sealed against
%  change by the 'set' method. 
%
%  A sealed field might be fixed, or only set according to the values of other fields that
%  can be set.
%
%  The list of sealed fields must be a cell array of field names. If there are no sealed fields
%  then you do not have to set sealed fields, or you can leave it as an empty strucure. The matlab
%  function struct that can be used to create the default configuration has confusing syntax for
%  this purpose: suppose we have fields called 'v1', 'v2', 'v3',...  then we might have:
%   - if no sealed fields:  ...,sealed_fields,{{''}},...
%   - if one sealed field   ...,sealed_fields,{{'v1'}},...
%   - if two sealed fields  ...,sealed_fields,{{'v1','v2'}},...
%
%  Note that 'sealed_fields' will be treated as a sealed field, whether or not it is in the list of
%  sealed fields. If 'sealed_fields' is not given at all, then a field will be created and set to
%  an empty cell.
%
%--------------------------------------------------------------------------------------------------
function config_data=default_config

config_data=struct(...
    'v1',10000000,...
    'v2',9 ...
    );
