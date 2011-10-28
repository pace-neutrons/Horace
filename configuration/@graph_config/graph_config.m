function this=graph_config
% Retrieve or create the current herbert configuration
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

% Initialise graphics styles
config_data=struct();
config_data.color{1}='k';
config_data.line_style{1} = '-';
config_data.line_width = 0.5;
config_data.marker_type{1} = 'o';
config_data.marker_size = 6;
config_data.xscale = 'linear';
config_data.yscale = 'linear';
config_data.zscale = 'linear';

config_data.oned_maxspec = 1000;
config_data.oned_binning = 1;

config_data.twod_maxspec = 1000;
config_data.twod_nsmooth = 0;

% Initialise default figure names
config_data.name_oned = 'Herbert 1D plot';
config_data.name_multiplot = 'Herbert multiplot';
config_data.name_stem = 'Herbert stem plot';
config_data.name_area = 'Herbert area plot';
config_data.name_surface = 'Herbert surface plot';
config_data.name_contour = 'Herbert contour plot';
config_data.name_sliceomatic = 'Sliceomatic';
config_data.sealed_fields = {'sealed_fields'};
