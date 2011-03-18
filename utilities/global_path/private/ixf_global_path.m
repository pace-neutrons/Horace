function varargout = ixf_global_path (operation, name, val)
% Utility routine for manipulating global paths. Gateway to hidden persistent variable.
%
% Exist:
%   >> status = ixf_global_path ('exist')           % check if any global paths exist
%   >> status = ixf_global_path ('exist', pathname) % check if named global path exists
%
% Delete:
%   >> ixf_global_path ('del', pathname)
%
% Get:
%   >> namcell = ixf_global_path ('get')            % cell array of names of all global paths
%   >> dircell = ixf_global_path ('get', pathname)  % cell array of directories in named path
%   >> dircell = ixf_global_path ('get', pathname, 'full')  % cell array of directories in named path
%                                                           % with global paths resolved
%
% Set:
%   >> ixf_global_path ('set', pathname, cellstr)

% Global paths must be non-empty if they exist. Ensusre this is always satisfied for the
% routines to be inernally consistent.

% Initiate a structure to store global paths
persistent global_paths
if ~isstruct(global_paths) && isempty(global_paths)
    global_paths=struct;     % make empty structure
end

% Check if name given
if exist('name','var')
    if ~isvarname(name)
        error('Global path name is not a valid variable name')
    end
    named=true;
else
    named=false;
end

% Perform requested operation
switch operation
    case 'exist'
        if ~named
            varargout{1} = ~isempty(global_paths);
        else
            varargout{1} = isfield(global_paths,name);
        end
        
    case 'del'
        if ~named
            error('Must give name of global path to be deleted')
        else
            if isfield(global_paths,name)
                global_paths=rmfield(global_paths,name);
            else
                error(['Global path named ''',name,'''  does not exist. Cannot be deleted.'])
            end
        end
        
    case 'get'
        if ~named
            varargout{1}=fieldnames(global_paths);
        else
            if isfield(global_paths,name)
                if ~exist('val','var')  % no option given
                    varargout{1}=global_paths.(name);
                elseif isequal(val,'full')
                    dirs=resolve_path(global_paths.(name));
                    [dummy,ind] = unique(dirs,'first');   % keep first occurence of any repeated directories
                     varargout{1} = dirs(sort(ind));       % unique directories in order of first appearance
                else
                    error('get: only valid optional argument is ''full''')
                end
            else
                error(['Global path named ''',name,'''  does not exist.'])
            end
        end
        
    case 'set'
        if ~named
            error('Must give name of global path to be set')
        else
            if exist('val','var') && iscellstr(val)
                % Must now check that no global paths will be recursive or too deeply nested
                % (expensive, but safest to do here, the only place where a global path can be altered)
                if ~nesting_ok(val(:))
                    error(['Global path named ''',name,''' is nested too deeply. Check definition is not recursive.'])
                end
                if isfield(global_paths,name)
                    old_global_path= true;
                    val_store = global_paths.(name);    % save current value of path, if exists
                else
                    old_global_path=false;
                end
                global_paths.(name) = val(:);  % overwrite any existing value, as column cellstr
                % Now check all global paths (including the one just set, but we will have already caught any errors here)
                names=fieldnames(global_paths);
                nesting_error=false;
                for i=1:numel(names)
                    if ~nesting_ok(global_paths.(names{i}))
                        if ~nesting_error
                            nesting_error=true;
                            disp('The following global paths will become too deeply nested:')
                        end
                        disp(['        ',names{i}])
                    end
                end
                if nesting_error
                    if old_global_path
                        global_paths.(name) =val_store;     % return to original value
                    else
                        global_paths=rmfield(global_paths,name);         % remove, because no prior value
                    end
                    error(['Global path named ''',name,''' induces one or more global paths to be too deep. Check definition(s) not recursive.'])
                end
            else
                error('Must give value of global path as a cell array of character strings')
            end
        end
        
    otherwise
        error('operation not recognised')
end

%------------------------------------------------------------------------------
function ok=nesting_ok(celldir,depth)
% Check the depth of nesting. Could be infinite if one global path calls another that calls the first
% This is fatal, so prevent from happening.

% Recursive function
% Also calls ixf_global_path recursively

if ~exist('depth','var')
    ok=true;
    depth=1;
elseif depth<20
    ok=true;
else
    ok=false;
    return
end

for i=1:numel(celldir)
    if isvarname(celldir{i})  % assume to be a global path
        if ixf_global_path('exist',celldir{i})
            ok=nesting_ok(ixf_global_path('get',celldir{i}),depth+1);
            if ~ok, return, end
        end
    end
end

%------------------------------------------------------------------------------
function fullcelldir = resolve_path (celldir)
% Reolve path into underlying directories

fullcelldir={};
for i=1:numel(celldir)
    if isvarname(celldir{i})  % assume to be a global path
        if ixf_global_path('exist',celldir{i})  % if doesn't exist, just skip
            fullcelldir = [fullcelldir; resolve_path(ixf_global_path('get',celldir{i}))];
        end
    else
        fullcelldir = [fullcelldir;celldir{i}];
    end
end
