function varargout = exist_global_var(varargin)
% Check existence of global variables which are hidden from the matlab workspace.
%
% Variables are stored in collections or 'variable sets'; a variable is
% addressed by giving both its name and the name of the set in which it is stored.
%
% Check if a variable set exists: (output true or false)
%   >> status = exist_global_var (var_setname)
%
% Check if a variable exists in a set: (output true or false)
%  - if give the names as separate arguments, return values as separate arguments:
%   >> [status1, status2,...] = exist_global_var (var_setname, name1, name2,...)
%
%  - if give a cell array of variable names, return arguments as logical array
%   >> status = exist_global_var (var_setname, name_cellstr)
%
%
% See also:
%   set_global_var, get_global_var, exist_global_var, remove_global_var, clear_global_var, copy_global_var

% Uses ixf_global_var to ensure compatibility

if nargin>0
    if nargin==1    % must catch this case to avoid {} being passed as a name
        varargout{1} = ixf_global_var (varargin{1}, 'exist');
    elseif nargin==2 && iscellstr(varargin{2})
        varargout{1} = ixf_global_var (varargin{1}, 'exist', varargin{2:end});
    else            % package arguments as cell; if valid names this will be a cellstr
        status = ixf_global_var (varargin{1}, 'exist', {varargin{2:end}});
        if nargin>2
            varargout=cell(size(status));
            for i=1:numel(status)
                varargout{i}=status(i);
            end
        else
            varargout{1}=status;
        end
    end
else
    error('Check input argument(s)')
end
