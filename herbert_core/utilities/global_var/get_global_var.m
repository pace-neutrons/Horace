function varargout = get_global_var(varargin)
% Get global variables which are hidden from the matlab workspace.
%
% Variables are stored in collections or 'variable sets'; a variable is
% addressed by giving both its name and the name of the set in which it is stored.
%
% Get cell array of variable names and a structure containing all variables in a variable set
% (with fields matching the variable names):
%   >> var_struct = get_global_var(var_setname)
%
% Get values of one or more specific variables in a set:
%  - if give the names as separate arguments, return values as separate arguments:
%   >> [val1,val2,...] = get_global_var(var_setname, name1, name2,...)
%
%  - if give a cell array of variable names, return arguments as fields of a structure
%   >> var_struct = get_global_var(var_setname, name_cellstr)
%
% Get cell array of the names of all variable sets:
%   >> var_setnames = get_global_var
%
%
% *** note: the behaviour is slightly different from ixf_global_var ( ...,'get',...):
%   >> var_struct = ixf_global_var(var_setname, 'get')    is now consistent with set, exist etc.
%
%   ixf_global_var returns empty value for variables that don't exist; this routine throws an error
%   if a variable does not exist
%
%
% See also:
%   set_global_var, get_global_var, exist_global_var, remove_global_var, clear_global_var, copy_global_var

% Uses ixf_global_var to ensure compatibility

if nargin>0
    if nargin==1    % must catch this case to avoid {} being passed as a name
        status = ixf_global_var (varargin{1}, 'exist');
        if status
            [dummy,varargout{1}] = ixf_global_var (varargin{1}, 'get');
        else
            error('Variable set does not exist')
        end
    elseif nargin==2 && iscellstr(varargin{2})
        status = ixf_global_var (varargin{1}, 'exist', varargin{2:end});
        if all(status)
            varargout{1} = ixf_global_var (varargin{1}, 'get', varargin{2:end});
        else
            error('Variable set or at least of the variables, does not exist')
        end
    else            % package arguments as cell; if valid names this will be a cellstr
        status = ixf_global_var (varargin{1}, 'exist', {varargin{2:end}});
        if all(status)
            var_struct = ixf_global_var (varargin{1}, 'get', varargin{2:end});
            if nargin>2
                varargout=cell(size(status));
                for i=1:numel(status)
                    varargout{i}=var_struct(i);
                end
            else
                varargout{1}=var_struct;
            end
        else
            error('Either the variable set, or at least of the variables, does not exist')
        end
    end
else
    varargout{1} = ixf_global_var;
end
