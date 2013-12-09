function display (this)
% Display a configuration to the screen
%
%   >> display (config_obj)  % config_obj is an instance of a configuration class


% $Revision$ ($Date$)

config_data=get(this);
config_name=class(this);
disp(' ')
disp([config_name,' ='])
disp(' ')
if isempty(config_data.sealed_fields)
    config_data=rmfield(config_data,'sealed_fields');
end
disp(config_data)
