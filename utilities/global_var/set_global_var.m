function set_global_var(varargin)
% Set global variables which are hidden from the matlab workspace.
%
% Variables are stored in collections or 'variable sets'; a variable is
% addressed by giving both its name and the name of the set in which it is stored.
%
% Create empty variable set:
%   >> set_global_var (var_setname)      
%
% Add (or overwrite) variables to a set (creates variable set if doesn't already exist):
%   >> set_global_var (var_setname, name1, val1, name2, val2, ...)
%
% Add (or overwrite) variables from a structure (creates variable set if doesn't already exist):
%   >> set_global_var (var_setname, var_struct)         
%
%
% See also:
%   set_global_var, get_global_var, exist_global_var, remove_global_var, clear_global_var, copy_global_var

% Uses ixf_global_var to ensure compatibility

if nargin>0
    if nargin==1
        ixf_global_var (varargin{1}, 'set');
    else
        ixf_global_var (varargin{1}, 'set', varargin{2:end});
    end
else
    error('Check input argument(s)')
end
