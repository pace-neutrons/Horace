function level = get_global_var_warning_level
% Set global variable warning level
%
%   >> level = get_global_var_warning_level
%
%   level       String with value: 'none', 'info', 'warning', 'error'

level = ixf_global_var_warning_level ('get');
