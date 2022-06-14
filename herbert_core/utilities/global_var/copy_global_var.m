function copy_global_var(varargin)
% Copies global variables which are hidden from the matlab workspace.
%
% Variables are stored in collections or 'variable sets'; a variable is
% addressed by giving both its name and the name of the set in which it is stored.
%
%   >> copy_global_var(var_setname, var_setname1, var_setname2,...) % copy to new set(s)
%   >> copy_global_var(var_setname, name_cell)        % copy to sets with names in cell array
%
%
% See also:
%   set_global_var, get_global_var, exist_global_var, remove_global_var, clear_global_var, copy_global_var

% Uses ixf_global_var to ensure compatibility

if nargin>1
    ixf_global_var (varargin{1}, 'copy', varargin{2:end});
else
    error('Check input argument(s)')
end
