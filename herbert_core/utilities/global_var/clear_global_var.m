function clear_global_var(varargin)
% Clears (i.e. sets to empty) global variables which are hidden from the matlab workspace.
%
% Variables are stored in collections or 'variable sets'; a variable is
% addressed by giving both its name and the name of the set in which it is stored.
%
%   >> clear_global_var(var_setname)                   % clear a set of variables
%   >> clear_global_var(var_setname, name1, name2,...) % clear particular variables in a set
%   >> clear_global_var(var_setname, name_cell)        % clear variables named in the cell array     
%
%
% See also:
%   set_global_var, get_global_var, exist_global_var, remove_global_var, clear_global_var, copy_global_var

% Uses ixf_global_var to ensure compatibility

if nargin>0
    if nargin==1
        ixf_global_var (varargin{1}, 'clear');
    else
        ixf_global_var (varargin{1}, 'clear', varargin{2:end});
    end
else
    error('Check input argument(s)')
end
