function varargout=ixf_global_var(varargin)
% Store and retrieve variables which are hidden from the matlab workspace.
%
% Variables are stored in collections or 'variable sets'; a variable is
% addressed by giving both its name and the name of the set in which it is stored.
% (A variable set is effectively a global structure, a variable in the set is a field
% of that structure.)
%
% To find out the names of all global variables
%
% Check if variables exist
% ------------------------
% Check if a variable set exists: (output true or false)
%   >> status = ixf_global_var (var_setname, 'exist')
%
% Check if a variable exists in a set: (output true or false)
%  - if give the names as separate arguments, return values as separate arguments:
%   >> [status1, status2,...] = ixf_global_var (var_setname, 'exist', name1, name2,...)
%
%  - if give a cell array of variable names, return arguments as logical array
%   >> status = ixf_global_var (var_setname, 'exist', name_cellstr)
%
%
% Set variables in a variable set
% -------------------------------
% Create empty variable set:
%   >> ixf_global_var (var_setname, 'set')      
%
% Add (or overwrite) variables to a set (creates variable set if doesn't already exist):
%   >> ixf_global_var (var_setname, 'set', name1, val1, name2, val2, ...)
%
% Add (or overwrite) variables from a structure (creates variable set if doesn't already exist):
%   >> ixf_global_var (var_setname, 'set', var_struct)     
%
%
% Get variables in a variable set
% -------------------------------
% Get cell array of variable names and a structure containing all variables in a variable set
% (with fields matching the variable names):
%   >> [var_names, var_struct] = ixf_global_var(var_setname, 'get')
%
% Get values of one or more specific variables in a set:
%  - if give the names as separate arguments, return values as separate arguments:
%   >> [val1,val2,...] = ixf_global_var(var_setname, 'get', name1, name2,...)
%
%  - if give a cell array of variable names, return arguments as fields of a structure
%   >> var_struct = ixf_global_var(var_setname, 'get', name_cellstr)
%
% Get cell array of the names of all variable sets:
%   >> var_setnames = ixf_global_var
%
%
% *** note: the 'get' syntax is anomalous when not given ant explicit: would expect that should be
%   >> var_struct = ixf_global_var(var_setname, 'get')
%     but does not for reasons of backwards compatibility. ***
%
% Remove or clear variables in a variable set
% -------------------------------------------
% Remove means the variables are deleted; clear means they are set to empty. Normally
% only 'remove' is needed.
%
%   >> ixf_global_var(var_setname,'remove')                   % remove a set of variables
%   >> ixf_global_var(var_setname,'remove', name1, name2,...) % remove particular variables in a set
%   >> ixf_global_var(var_setname,'remove', name_cell)        % remove variables named in the cell array
%
%   >> ixf_global_var(var_setname,'clear')                    % clear a set of variables
%   >> ixf_global_var(var_setname,'clear', name1, name2,...)  % clear particular variables in a set
%   >> ixf_global_var(var_setname,'clear', name_cell)         % clear variables named in the cell array
%
%
% Copy variable sets from one variable set to another
% ---------------------------------------------------
% Copy a variable set to one or more other variable sets, replacing any existing variables
%
%   >> ixf_global_var(var_setname, 'copy', var_setname1, var_setname2,...) % copy to new set(s)
%   >> ixf_global_var(var_setname, 'copy', var_setname_cell)    % copy to sets with names in cell array
%

% Orignal code: 14/09/2007, Dean Whittaker
% Re-written:   27/01/2009, T.G.Perring
% Changes:
% 26/02/2011 T.G.Perring: bug fixes
%
% Notes:
% --------
% Global variable names accessed by this function are stored as fields of a
% persistent structure called main_struct:
%
%   main_struct.setname1
%   main_struct.setname2
%           :
% The names of the variables in a set are the field names within setame1, setname2,...
%   setname.var1
%   setname.var2
%         :
%
% This means that the names of global variables must form valid variable names
%
%
% Notes on robustness of argument checking:
% - isfield(struct,var) is robust even if var is not a valid variable name, structure etc.
% - isvarname(var) also is robust
% - strcmp seems to work even if one or both items sent to it are not strings
%
% Notes on filling structures:
% - struct([]) creates a [0x0] structure with no fields
% - struct  creates a [1x1] structure with no fields - which is our convention for
%           a global variable that has been cleared or created but not filled 


% Initiate a structure to store everything
mlock;  % for stability
persistent main_struct  

if ~isstruct(main_struct) && isempty(main_struct)
    main_struct=struct;     % make empty structure
end

% Get error level:
[level,none_flag,info_flag,warning_flag,error_flag]=ixf_global_var_warning_level('get');

% Special case of getting the whole set of global variables
if nargin==0 || nargin==1 && strcmpi(varargin{1},'get')
    varargout{1}=fields(main_struct);
    if nargout==2
        varargout{2}=main_struct;
    end
    return
end

% Check property set name is valid
if isvarname(varargin{1})
    var_setname=varargin{1};
    if isfield(main_struct, varargin{1})
        var_set_exist=true;
    else
        var_set_exist=false;
    end
else
    error('Global property set name must be a valid Matlab variable name - check type of input.')
end


% Check keyword is valid to use in a switch construct
if nargin==1
    keywrd='get';   % no keyword is interpreted as 'get'
elseif isscalar(varargin{2})||ischar(varargin{2})
    keywrd=varargin{2};
    if ischar(keywrd)
        keywrd=lower(keywrd);
    end
else
    error('Keyword not recognised')
end

% Branch on keyword
switch keywrd
    case 'exist'
        if nargin==2
            if var_set_exist
                varargout{1}=true;
            else
                varargout{1}=false;
            end
        else
            % Argument following the 'exist'
            if nargin==3 && iscellstr(varargin{3})
                args=varargin{3};   % was a cellstr, so interpret as variable names
            else
                args=varargin(3:end);
            end
            % Check all names are valid before doing any actions
            for i=1:numel(args)     
                if ~isvarname(args{i})
                    error('Not all property names have valid Matlab variable names - check type(s) of input.')
                end
            end
            % Find out which variables exist and fill output accordingly
            if ~var_set_exist
                info_mess=['Property set with name ''',var_setname,''' does not exist.'];
                error_mess=['Property set with name ''',var_setname,''' does not exist.'];
                if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
                status=repmat({false},size(args));
            else
                status=cell(size(args));
                for i=1:numel(args)
                    if isfield(main_struct.(var_setname), args{i})
                        status{i}=true;
                    else
                        status{i}=false;
                    end
                end
            end
            % Repackage output according to type of input
            if iscellstr(varargin{3})
                varargout{1}=cell2mat(status);
            else
                varargout=status;
            end
        end

    case 'get'
        if nargin<=2
            % Arguments are: (var_setname) or (var_setname,'get')
            if ~var_set_exist
                info_mess=['Property set with name ''',var_setname,''' does not exist. Empty return.'];
                error_mess=['Property set with name ''',var_setname,''' does not exist.'];
                if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
                varargout{1}={};
                if nargout==2
                    varargout{2}=struct;
                end
            else
                varargout{1}=fields(main_struct.(var_setname));
                if nargout==2
                    varargout{2}=main_struct.(var_setname);
                end
            end

        else
            % Argument following the 'get'
            if nargin==3 && iscellstr(varargin{3})
                args=varargin{3};   % was a cellstr, so interpret as variable names
            else
                args=varargin(3:end);
            end
            % Check all names are valid before doing any actions
            for i=1:numel(args)     
                if ~isvarname(args{i})
                    error('Not all property names have valid Matlab variable names - check type(s) of input.')
                end
            end
            % Find out which variables exist and fill output accordingly
            vals=cell(size(args));  % cell array of empty doubles, []
            if ~var_set_exist
                info_mess=['Property set with name ''',var_setname,''' does not exist.'];
                error_mess=['Property set with name ''',var_setname,''' does not exist.'];
                if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
            else
                for i=1:numel(args)
                    if isfield(main_struct.(var_setname), args{i})
                        vals{i}=main_struct.(var_setname).(args{i});
                    else
                        info_mess=['Property with name ''',args{i},''' does not exist in property set ''',var_setname,'''. Value returned = [].'];
                        error_mess=['Property with name ''',args{i},''' does not exist in property set ''',var_setname,'''.'];
                        if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
                    end
                end
            end
            % Repackage output according to type of input
            if iscellstr(varargin{3})
                varargout{1}=cell2struct(vals(:),args,1);     % need to make values a column vector
            else
                varargout=vals;
            end
        end

    case 'set'
        if nargin==2            % Create an empty global variable if doesn't already exist; otherwise do nothing
            if ~var_set_exist
                main_struct.(var_setname)=struct;
            end
        elseif nargin==3 && isstruct(varargin{3})   % set to the given structure
            main_struct.(var_setname)=varargin{3};
        elseif rem(nargin,2)==0 % even number of arguments
            for i=3:2:nargin    % check all names are valid before adding fields
                if ~isvarname(varargin{i})
                    error('Not all property names to be set have valid Matlab variable names. No ''set'' performed.')
                end
            end
            for i=3:2:nargin
                main_struct.(var_setname).(varargin{i})=varargin{i+1};
            end
        else
            error('Check argument(s) to global variable ''set'' function form name,value pairs or a structure. No ''set'' performed.')
        end
            
    case 'clear'
        if ~var_set_exist
            info_mess=['Property set with name ''',var_setname,''' does not exist. No ''clear'' possible.'];
            error_mess=['Property set with name ''',var_setname,''' does not exist. No ''clear'' actions performed.'];
            if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
            return
        end
        if nargin==2
            main_struct.(var_setname)=struct;
        else
            if nargin==3 && iscellstr(varargin{3})
                args=varargin{3};   % was a cellstr, so interpret as variable names
            else
                args=varargin(3:end);
            end
            % Check all names are valid before doing any clear actions
            for i=1:numel(args)
                if ~isvarname(args{i})
                    error('Not all property names have valid Matlab variable names. No ''clear'' actions performed.')
                end
            end
            % Clear variables
            for i=1:numel(args)
                if isfield(main_struct.(var_setname), args{i})
                    main_struct.(var_setname).(args{i})=[];
                else
                    info_mess=['Property with name ''',args{i},''' does not exist in property set ''',var_setname,'''. No ''clear'' possible.'];
                    error_mess=['Property with name ''',args{i},''' does not exist in property set ''',var_setname,'''. No ''clear'' actions performed.'];
                    if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
                end
            end
        end
            
    case 'remove'
        if ~var_set_exist
            info_mess=['Property set with name ''',var_setname,''' does not exist. No ''remove'' possible.'];
            error_mess=['Property set with name ''',var_setname,''' does not exist. No ''remove'' actions performed.'];
            if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
            return
        end
        if nargin==2
            main_struct=rmfield(main_struct,var_setname);
        else
            if nargin==3 && iscellstr(varargin{3})
                args=varargin{3};   % was a cellstr, so interpret as variable names
            else
                args=varargin(3:end);
            end
            % Check all names are valid before doing any remove actions
            for i=1:numel(args)
                if ~isvarname(args{i})
                    error('Not all property names have valid Matlab variable names. No ''remove'' actions performed.')
                end
            end
            % Remove variables
            for i=1:numel(args) % remove one at a time because if there are duplicate names in args this will cause an error otherwise
                if isfield(main_struct.(var_setname), args{i})
                    main_struct.(var_setname)=rmfield(main_struct.(var_setname),args{i});
                else
                    info_mess=['Property with name ''',args{i},''' does not exist in property set ''',var_setname,'''. No ''clear'' possible.'];
                    error_mess=['Property with name ''',args{i},''' does not exist in property set ''',var_setname,'''. No ''clear'' actions performed.'];
                    if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
                end
            end
        end
        
    case 'copy'
        if ~var_set_exist
            info_mess=['Property set with name ''',var_setname,''' does not exist. No ''copy'' possible.'];
            error_mess=['Property set with name ''',var_setname,''' does not exist. No ''copy'' actions performed.'];
            if error_flag, error(error_mess), elseif warning_flag, warning(info_mess), elseif info_flag, disp(info_mess), end
            return
        end
        if nargin==2
            error('Must give property set name to which to copy.')
        else
            if nargin==3 && iscellstr(varargin{3})
                args=varargin{3};   % was a cellstr, so interpret as variable names
            else
                args=varargin(3:end);
            end
            % Check all names are valid before doing any copy actions
            for i=1:numel(args)     
                if ~isvarname(args{i})
                    error('Not all output property set names are Matlab variable names. No copying performed.')
                end
            end
            for i=1:numel(args)
                main_struct.(args{i})=main_struct.(var_setname);
            end
        end
        
    otherwise
        error('Keyword not recognised')
end
