function display (this)
% Display a configuration to the screen

% $Revision$ ($Date$)

config_data=get(this);
config_name=class(this);
disp(' ')
disp([config_name,' ='])
disp(' ')
disp(config_data)
