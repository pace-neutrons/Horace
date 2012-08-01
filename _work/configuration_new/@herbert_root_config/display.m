function display (this)
% Display a configuration to the screen

% $Revision: 122 $ ($Date: 2011-12-23 16:33:53 +0000 (Fri, 23 Dec 2011) $)

config_data=get(this);
config_name=class(this);
disp(' ')
disp([config_name,' ='])
disp(' ')
disp(config_data)
