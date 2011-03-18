function set_global_var_warning_level(level)
% Set global variable warning level
%
%   >> set_global_var_warning_level(level)
%
%   level       String with value: 'none', 'info', 'warning', 'error'

ixf_global_var_warning_level ('set', level);
