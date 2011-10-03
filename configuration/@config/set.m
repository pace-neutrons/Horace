function this=set(this,varargin)
% Set one or more fields in a configuration
%
%   >> var = set(config, field1, val1, field2, val2, ... )
%   >> var = set(config, struct )
%   >> var = set(config, cellarray)     % cell array has the form {field1,val1,field2,val2,...}
%   >> var = set(config,'defaults')


config_name = class(this);               % class name of incoming object
root_config_name = mfilename('class');   % the class for which this a method
file_name = config_file_name (config_name);

% Cannot alter fields of parent class
if strcmp(config_name,root_config_name)
    error(['Trying to alter a field in hidden cconfiguration ''',root_config_name,''''])
end

% Parse arguments;
narg = length(varargin);
if narg==1
    svar = varargin{1};
    if ischar(svar) && strncmpi(svar,'defaults',length(svar))
        % Set fields to default values, store in memory and on file, and return
        fetch_default = true;
        default_config_data = config_store(config_name,fetch_default);
        [ok,mess]=save_config(file_name,default_config_data);
        if ~ok, error(mess), end
        config_store(config_name,default_config_data);
        return;
    elseif isstruct(svar)
        field_nams = fieldnames(svar);
        field_vals = cell(1,numel(field_nams));
        for i=1:numel(field_nams)
            field_vals{i}=svar.(field_nams{i});
        end
    elseif iscell(svar)
        if isempty(svar) || rem(numel(svar),2)~=0
            error('Incomplete set of (field,value) pairs given')
        end
        field_nams  = svar{1:2:end};
        field_vals  = svar{2:2:end};
    else
        error('Second parameter has to be a structure, a cell array, or the option ''defaults''')
    end
    
else
    if rem(narg,2)==0
        field_nams = varargin(1:2:narg);
        field_vals = varargin(2:2:narg);
    else
        error('Incomplete set of (field,value) pairs given')
    end
end

% Check arguments
if ~all_strings(field_nams)
    error('All field_names have to be strings');
end

% Get access to the internal structure
fetch_default = false;
config_data = config_store(config_name,fetch_default);
config_fields = fieldnames(config_data);

% Check if any fields being altered are sealed fields or the root config class
sealed_fields=ismember(config_data.sealed_fields,field_nams);
if any(sealed_fields);    
    error('The values of some fields are sealed and can not be altered');
end
if ismember(root_config_name,field_nams);
    error(['Cannot alter hidden field ''',root_config_name,''''])
end

% Check fields to be altered are in the valid name list
member_fields = ismember(config_fields,field_nams);
if sum(member_fields)~=numel(field_vals)
    error('Configuration ''%s'' does not have one or more of the fields you are trying to set',config_name);
end

% *** Check that none of the new values contains the root config class anwhere -
% we do not allow a configuration to depend on any other configuration


% Set the fields
for i=1:numel(field_nams)
    config_data.(field_nams{i})=field_vals{i};
end

% Save data into the corresponding configuration file and into memory;
[ok,mess]=save_config(file_name,config_data);
if ~ok, error(mess), end
config_store(config_name,config_data)


%--------------------------------------------------------------------------------------------------
function ok=all_strings(c)
% Check elements of a cell array are 1xn non-empty character strings
ok=true;
for i=1:numel(c)
    ok=ischar(c{i}) && ~isempty(c{i}) && size(c{i},1)==1;
end
