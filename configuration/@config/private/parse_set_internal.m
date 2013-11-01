function [S,save,ok,mess] = parse_set_internal (this, change_sealed, varargin)
% Check arguments are valid for set methods. Throws an error if not.
%
% Set save-to-file flag as '-save':
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, change_sealed, field1, val1, field2, val2, ...)
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, change_sealed, struct)
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, change_sealed, cellnam, cellval) % Cell arrays of field names and values
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, change_sealed, cellarray)        % Cell array has the form {field1,val1,field2,val2,...}
%
% Cases that return all fields (and save-to-file flag set to '-save')
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, change_sealed)                   % Returns current values
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, change_sealed, 'defaults')       % Returns default values
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, change_sealed, 'saved')          % Returns saved values
%
% All the above follow the default behaviour to save to file:
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, ..., '-save')
%
% Set save-to-file flag as '-buffer':
%   >> [S,save,ok,mess] = parse_set_internal (config_obj, change_sealed, ..., '-buffer')
%
% Input:
% ------
%   config_obj      Configuration object
%   change_sealed   Indicates if sealed fields can be altered.
%                   '-change_sealed' or '-nochange_sealed'
%                         true       or        false
%                           1        or          0
%
% Output:
% -------
%   S               Structure with the fields of configuration object, and with
%                  values updated according to the input arguments
% 
%   save            Save-to-file request: '-save' (save to file) or '-buffer' (save in buffer only)
%
%   ok              True if all ok, false otherwise
%
%   mess            Error message if not ok; ='' otherwise
% 
%
% EXAMPLES:
%   >> [S,save,ok,mess] = parse_set_internal (my_config,'a',10,'b','something')
%
%   >> [S,save,ok,mess] = parse_set_internal (my_config,'a',10,'b','something','-buffer')
%
%   >> [S,save,ok,mess] = parse_set_internal (test_config,'v1',[10,14],'v2',{'hello','Mister'})
%
%
% NOTE: For internal use only.

% $Revision$ ($Date$)

% Default return values
S={};
save='';
ok=true;
mess='';

narg = length(varargin);
config_name = class(this);               % class name of incoming object
file_name = config_file_name (config_name);

% Get the value of change_sealed
% ------------------------------
if isscalar(change_sealed) && (islogical(change_sealed) || (isnumeric(change_sealed) && (change_sealed==0 ||change_sealed==1)))
    change_sealed=logical(change_sealed);
elseif ischar(change_sealed) && size(change_sealed,1)==1
    if strcmp(change_sealed,'-change_sealed')
        change_sealed=true;
    elseif strcmp(change_sealed,'-nochange_sealed')
        change_sealed=false;
    else
        ok=false; mess='Argument ''change_sealed'' can only have the value ''-change_sealed'' or ''-nochange_sealed'', or 1 or 0'; return
    end
else
    ok=false; mess='Argument ''change_sealed'' can only have the value ''-change_sealed'' or ''-nochange_sealed'', or 1 or 0'; return
end

% Determine if '-buffer' option appears at the end of the argument list
% ---------------------------------------------------------------------
save='-save';
if narg>0 && ischar(varargin{end}) && ~isempty(varargin{end}) && size(varargin{end},1)==1 && size(varargin{end},2)>1
    if strncmpi(varargin{end},'-saved',length(varargin{end}))
        narg=narg-1;
    elseif strncmpi(varargin{end},'-buffer',length(varargin{end}))
        save='-buffer';
        narg=narg-1;
    end
end

% Parse other arguments
% ---------------------
if narg==0
    % Catch case of no other arguments: fetch current values and return
    fetch_default = false;
    S = config_store(config_name,fetch_default);
    return

elseif narg==1
    % Structure, cell array of field name/value pairs, or special option
    svar = varargin{1};
    if isstruct(svar)
        field_nams = fieldnames(svar);
        field_vals = struct2cell(svar);
        
    elseif iscell(svar)
        if isempty(svar) || rem(numel(svar),2)~=0
            ok=false; mess='Incomplete set of (fieldname,value) pairs given'; return
        end
        field_nams = svar{1:2:end}(:);
        field_vals = svar{2:2:end}(:);
        if ~valid_fieldnames(field_nams)
            ok=false; mess='Field name arguments are not all valid field names for a structure'; return
        end
        if numel(unique(field_nams))~=numel(field_nams)
            ok=false; mess='One or more name arguments are repeated'; return
        end
    
    elseif ischar(svar) && strncmpi(svar,'defaults',length(svar))
        % Fetch default values and return
        fetch_default = true;
        S = config_store(config_name,fetch_default);
        return
        
    elseif ischar(svar) && strncmpi(svar,'saved',length(svar))
        % Fetch saved values and return
        [S,ok,mess] = load_config (file_name);
        if ~ok, return, end
        return
       
    else
        ok=false; mess='Second parameter of two has to be a structure, a cell array, or the option ''defaults'''; return
    end

elseif narg==2 && iscell(varargin{1}) && iscell(varargin{2})
    % Cell array of field names and a cell array values
    field_nams = varargin{1}(:);
    field_vals = varargin{2}(:);
    if numel(field_nams)~=numel(field_vals)
        ok=false; mess='Numbers of field names and field values do not match'; return
    elseif ~valid_fieldnames(field_nams)
        ok=false; mess='Cell array of field names not all valid field names for a structure'; return
    elseif numel(unique(field_nams))~=numel(field_nams)
        ok=false; mess='One or more name arguments are repeated'; return
    end
    
else
    % Field name/value pairs
    if rem(narg,2)==0
        field_nams = varargin(1:2:narg);
        field_vals = varargin(2:2:narg);
        if ~valid_fieldnames(field_nams)
            ok=false; mess='Field name arguments are not all valid field names for a structure'; return
        elseif numel(unique(field_nams))~=numel(field_nams)
            ok=false; mess='One or more name arguments are repeated'; return
        end
    else
        ok=false; mess='Incomplete set of (fieldname,value) pairs given'; return
    end
end

% If got this far, then have a cell array of unique strings that could be field names, and a cell array of values
% ---------------------------------------------------------------------------------------------------------------
% Get access to the internal structure of the configuration
fetch_default = false;
S = config_store(config_name,fetch_default);
config_fields = fieldnames(S);

% Check fields to be altered are in the valid name list
if sum(ismember(field_nams,config_fields))~=numel(field_nams)
    ok=false; mess=['Configuration ''',config_name,''' does not have one or more of the fields you are trying to set']; return
end

% Check if any fields being altered are sealed fields
is_sealed_field=ismember(field_nams,S.sealed_fields);
if any(is_sealed_field)
    if change_sealed
        ind=find(strcmp('sealed_fields',field_nams),1);
        if ~isempty(ind) % one of the values to be changed is 'sealed_fields' itself (and only one, as already checked field_nams are unique)
            ok=false; mess='It is not permitted to change the list of sealed fields'; return
        end
    else
        ok=false; mess='An attempt to alter sealed fields is not permitted'; return
    end
end

% Update fields in the structure
for i=1:numel(field_nams)
    S.(field_nams{i})=field_vals{i};
end
