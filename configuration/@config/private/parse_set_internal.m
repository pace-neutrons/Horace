function S = parse_set_internal (this, change_sealed, varargin)
% Check arguments are valid for set methods. Throws an error if not.
%
%   >> S = parse_set_internal (config_obj, change_sealed, field1, val1, field2, val2, ...)
%   >> S = parse_set_internal (config_obj, change_sealed, struct)
%   >> S = parse_set_internal (config_obj, change_sealed, cellnam, cellval) % cell arrays of field names and values
%   >> S = parse_set_internal (config_obj, change_sealed, cellarray)        % cell array has the form {field1,val1,field2,val2,...}
%
%   >> S = parse_set_internal (config_obj, change_sealed)                   % returns current values
%   >> S = parse_set_internal (config_obj, change_sealed, 'defaults')       % returns default values
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
%   S           Structure whose fields and values are those to be changed
%               in the configuration object
% 
%
% EXAMPLES:
%   >> S = parse_set (my_config,'a',10,'b','something')
%
%   >> S = parse_set (test_config,'v1',[10,14],'v2',{'hello','Mister'})
%
%
% NOTE: For internal use only.

% $Revision: 120 $ ($Date: 2011-12-20 18:18:12 +0000 (Tue, 20 Dec 2011) $)


config_name = class(this);               % class name of incoming object
narg = length(varargin);

% Get the value of change_sealed
if isscalar(change_sealed) && (islogical(change_sealed) || (isnumeric(change_sealed) && (change_sealed==0 ||change_sealed==1)))
    change_sealed=logical(change_sealed);
elseif ischar(change_sealed) && size(change_sealed,1)==1
    if strcmp(change_sealed,'-change_sealed')
        change_sealed=true;
    elseif strcmp(change_sealed,'-nochange_sealed')
        change_sealed=false;
    else
        error('Argument ''change_sealed'' can only have the value ''-change_sealed'' or ''-nochange_sealed'', or 1 or 0')
    end
else
    error('Argument ''change_sealed'' can only have the value ''-change_sealed'' or ''-nochange_sealed'', or 1 or 0')
end

% Parse other arguments;
if narg==0
    fetch_default = false;
    S = config_store(config_name,fetch_default);
    return
        
elseif narg==1
    svar = varargin{1};
    if isstruct(svar)
        field_nams = fieldnames(svar);
        field_vals = struct2cell(svar);
        
    elseif iscell(svar)
        if isempty(svar) || rem(numel(svar),2)~=0
            error('Incomplete set of (fieldname,value) pairs given')
        end
        field_nams = svar{1:2:end}(:);
        field_vals = svar{2:2:end}(:);
        if ~valid_fieldnames(field_nams)
            error('Field name arguments are not all valid field names for a structure')
        end
        if numel(unique(field_nams))~=numel(field_nams)
            error('One or more name arguments are repeated')
        end
    
    elseif ischar(svar) && strncmpi(svar,'defaults',length(svar))
        fetch_default = true;
        S = config_store(config_name,fetch_default);
        return
        
    else
        error('Second parameter of two has to be a structure, a cell array, or the option ''defaults''')
    end

elseif narg==2 && iscell(varargin{1}) && iscell(varargin{2})
    field_nams = varargin{1}(:);
    field_vals = varargin{2}(:);
    if numel(field_nams)~=numel(field_vals)
        error('Numbers of field names and field names do not match')
    elseif ~valid_fieldnames(field_nams)
        error('Cell array of field names not all valid field names for a structure')
    elseif numel(unique(field_nams))~=numel(field_nams)
        error('One or more name arguments are repeated')
    end
    
else
    if rem(narg,2)==0
        field_nams = varargin(1:2:narg);
        field_vals = varargin(2:2:narg);
        if ~valid_fieldnames(field_nams)
            error('Field name arguments are not all valid field names for a structure')
        elseif numel(unique(field_nams))~=numel(field_nams)
            error('One or more name arguments are repeated')
        end
    else
        error('Incomplete set of (fieldname,value) pairs given')
    end
end

% If got this far, then have a cell array of strings that could be field names, and a cell array of values
% --------------------------------------------------------------------------------------------------------
% Get access to the internal structure of the configuration
fetch_default = false;
config_data = config_store(config_name,fetch_default);
config_fields = fieldnames(config_data);

% Check fields to be altered are in the valid name list
member_fields = ismember(field_nams,config_fields);
if sum(member_fields)~=numel(field_nams)
    error('Configuration ''%s'' does not have one or more of the fields you are trying to set',config_name);
end

% Check if any fields being altered are sealed fields (allow for possibility that sealed_fields does not contain 'sealed_fields')
is_sealed_fields=strcmp(field_nams,'sealed_fields');
sealed_fields=ismember(field_nams,config_data.sealed_fields) | is_sealed_fields;
if any(sealed_fields)
    if change_sealed
        if any(is_sealed_fields) % one of the values is 'sealed_fields' (and only one, as already checked field_nams are unique)
            val=field_vals(is_sealed_fields);
            [ok,mess]=valid_sealed_fields(val{1},config_fields);
            if ~ok
                error(mess)
            end
        end
    else
        error('An attempt to alter sealed fields is not permitted')
    end
end

% Return the fields to be changed as a structure
S=cell2struct(field_vals(:),field_nams(:));
