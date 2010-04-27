function conf=hdf_config()
% the constructor describing horace-hdf configuration and providing singleton
% behaviour.
% Do not inherit your configuration classes from this class; 
% Inherit from the basic class config instead
%
%
% $Revision$ ($Date$)
%

%this_class_name=mfilename('class');
this_class_name = 'hdf_config';
global configurations;
%
% this is generig code which has to be copied to any consrucor, inheriting
% from the class "config"
[is_in_memory,n_this_class,child_structure] = build_child(config,@init_hdf_default_value,this_class_name);
if is_in_memory
    conf=configurations{n_this_class};
else
    conf = class(child_structure,this_class_name,configurations{1});
    configurations{n_this_class}=conf;
end


function hdf_defaults=init_hdf_default_value()
% this function returns default values and behaviour of the 
% deals with the class specific structure;

    hdf_defaults=struct(...
        'hdf_allowed',true, ...      % Matlab can use hdf
        'use_hdf',false,...           % Horace has to use hdf 
        'hdf_fail_on_new',false,...  % what to do if hdf-tools constructor starts with empty file. Create a new hdf file or fail on creation?
        'hdf_restricted',true ...    % hdf at matlab 2009a and below? has restricted set of hdf commands
    );


   hdf_defaults.fields_sealed={'hdf_allowed','fields_sealed',...
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
    


