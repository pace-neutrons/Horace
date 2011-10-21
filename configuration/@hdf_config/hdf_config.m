function this=hdf_config()
% the constructor describing horace-hdf configuration and providing singleton
% behaviour.
% Do not inherit your configuration classes from this class; 
% Inherit from the basic class config instead
%
%
% $Revision$ ($Date$)
%

% This block contains generic code. Do not alter. Alter only the sub-function default_config below
global class_configurations_holder;

if ~isstruct(class_configurations_holder)
    class_configurations_holder = struct([]);
end
config_name=mfilename('class');
if ~isfield(class_configurations_holder,config_name)
    build_configuration(config,@init_hdf_default_value,config_name);    
    class_configurations_holder.(config_name)=class(struct([]),config_name,config);
end
this = class_configurations_holder.(config_name);


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


function hdf_defaults=init_hdf_default_value()
% this function returns default values and behaviour of the 
% deals with the class specific structure;

    hdf_defaults=struct(...
        'hdf_allowed',true, ...      % Matlab can use hdf
        'use_hdf',false,...           % Horace has to use hdf 
        'hdf_fail_on_new',false,...  % what to do if hdf-tools constructor starts with empty file. Create a new hdf file or fail on creation?
        'hdf_restricted',true, ...    % hdf at matlab 2009a and below? has restricted set of hdf commands
        'hdf_compression',3 ...       % number from 0 to 9 describing the compression level for hdf files
    );


   hdf_defaults.sealed_fields={'sealed_fields','hdf_allowed',...
                               'hdf_restricted'};
                          
% configure hdf
    Matlab_Version=matlab_version_num();
    if(Matlab_Version>=7.08) % Matlab supports hdf5 1.8
        hdf_defaults.hdf_allowed = true;
    else
        hdf_defaults.hdf_allowed = false;
        hdf_defaults.use_hdf     = false;       
    end
    if Matlab_Version>=7.09 % Matlab supports full hdf5 1.8 set of commands
        hdf_defaults.hdf_restricted=false;
    else
        hdf_defaults.hdf_restricted=true;        
    end
    


