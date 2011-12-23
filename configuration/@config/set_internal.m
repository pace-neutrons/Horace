function this=set_internal(this,change_sealed,varargin)
% Set one or more fields in a configuration, optionally allowing the sealed fields to be changed
%
%   >> var = set_internal (configobj, change_sealed, arg1, arg2, ...)
%
% Input:
%   configobj       Configuration object
%   change_sealed   Indicates if sealed fields can be altered.
%                   '-change_sealed' or '-nochange_sealed'
%                         true       or        false
%                           1        or          0
%   arg1, arg2,...  Arguments according to one of the useage options below
%
% Output:
%   var             Copy of configuration object
%
% Syntax for different input arguments:
% -------------------------------------
%   >> var = set_internal(configobj, change_sealed, field1, val1, field2, val2, ... )
%   >> var = set_internal(configobj, change_sealed, struct )
%   >> var = set_internal(configobj, change_sealed, cellnam, cellval)  % cell arrays of field names and values
%   >> var = set_internal(configobj, change_sealed, cellarray)         % cell array has the form {field1,val1,field2,val2,...}
%
%   >> var = set_internal(configobj, change_sealed)                    % Leaves configobj unchanged
%   >> var = set_internal(configobj, change_sealed,'defaults')         % Sets to default values configuration

% NOTE: This method has to be public because it is used by customised set methods
%       configuration objects. It should not be used in any other context.
%
% $Revision$ ($Date$)


% Get the value of change_sealed
if isscalar(change_sealed) && (islogical(change_sealed) || (isnumeric(change_sealed) && (change_sealed==0 ||change_sealed==1)))
    change_sealed=logical(change_sealed);
elseif ischar(change_sealed) && size(change_sealed,1)==1
    if strcmp(change_sealed,'-change_sealed')
        change_sealed=true;
    elseif strcmp(change_sealed,'-nochange_sealed')
        change_sealed=false;
    else
        error('Argument ''change_sealed'' can only have the value ''-change_sealed'' or ''-nochange_sealed'', or 0 or 1')
    end
else
    error('Argument ''change_sealed'' can only have the value ''-change_sealed'' or ''-nochange_sealed'', or 0 or 1')
end

% Pick up a couple of special cases without calling parse_set. Parse_set will handle them
% identically, but this saves duplication of working
narg = length(varargin);
config_name = class(this);               % class name of incoming object
file_name = config_file_name (config_name);

if narg==0
    % Do nothing
    return
    
elseif narg==1 && ischar(varargin{1}) && strncmpi(varargin{1},'defaults',length(varargin{1}))
    % Set fields to default values, store in memory and on file, and return
    fetch_default = true;
    default_config_data = config_store(config_name,fetch_default);
    [ok,mess]=save_config(file_name,default_config_data);
    if ~ok, error(mess), end
    config_store(config_name,default_config_data);
    return;
    
else
    S = parse_set_internal(this,change_sealed,varargin{:});
    % *** Should check that none of the new values contains the root config class anwhere
    % Get access to the internal structure
    fetch_default = false;
    config_data = config_store(config_name,fetch_default);
    % Set the fields
    field_nams=fieldnames(S);
    for i=1:numel(field_nams)
        config_data.(field_nams{i})=S.(field_nams{i});
    end
    % Save data into the corresponding configuration file and into memory;
    [ok,mess]=save_config(file_name,config_data);
    if ~ok, error(mess), end
    config_store(config_name,config_data)
    
end
