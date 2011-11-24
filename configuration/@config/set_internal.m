function set_internal(this,varargin)
% this is protected function which should be only invoked by the 
% set functions deployed by @config-class childrents;
%
%   >> set_internal(config,field1, val1, field2, val2, ... )
%   >> set_internal(config,'-change_sealed',field1, val1, field2, val2, ... )
%   >> set_internal(config,'-change_sealed',struct )
%   >> set_internal(config,struct )
%   >> set_internal(config,'-change_sealed',cellarray)     % cell array has the form {field1,val1,field2,val2,...}
%   >> set_internal(config,'defaults')
%
% where 
% config           -- the name of the @config class, identifying this function
% '-change_sealed' -- optional string, which modifies  - name of the class-child for the @config class
% other parameters    specify the values, which have to be stored in 
%                     configuration. 
% 
% 
% $Revision$ ($Date$)
%

% verify if the first argument allows changes to sealed fields
% this option is needed for overloading set
if ischar(varargin{1}) && strcmp(varargin{1},'-change_sealed')
    argi ={varargin{2:end}};
    forbid_sealed = false;    
else
    argi         = {varargin{:}};    
    forbid_sealed = true;
end
%
%
config_name      = class(this);          % class name of incoming object
file_name        = config_file_name (config_name);
% Parse arguments;
if nargin==2 && ischar(argi{1}) && strncmpi(argi{1},'defaults',3)
       % Set fields to default values, store in memory and on file, and return
        fetch_default = true;
        default_config_data = config_store(config_name,fetch_default);
        [ok,mess]=save_config(file_name,default_config_data);
        if ~ok, error(mess), end
        config_store(config_name,default_config_data);
        return;
   
else
    [field_nams,field_vals]=parse_config_arg(argi{:});
end    

% Check arguments
if ~all_strings(field_nams)
    error('All field_names have to be strings');
end

% Get access to the internal structure
fetch_default = false;
config_data   = config_store(config_name,fetch_default);
config_fields = fieldnames(config_data);


% Check if any fields being altered are sealed fields and throw error if
% they are
if forbid_sealed
    sealed_fields=ismember(config_data.sealed_fields,field_nams);
    if any(sealed_fields);    
        error('The values of some fields are sealed and can not be altered');
    end
end

% Check fields to be altered are in the valid name list
member_fields = ismember(config_fields,field_nams);
if sum(member_fields)~=numel(field_vals)
    error('CONFIG:set','Configuration ''%s'' does not have one or more of the fields you are trying to set',config_name);
end




% Set the fields
for i=1:numel(field_nams)
    config_data.(field_nams{i})=field_vals{i};
end

% Save data into the corresponding configuration file and into memory;
[ok,mess]=save_config(file_name,config_data);
if ~ok, error(mess), end
config_store(config_name,config_data);


%--------------------------------------------------------------------------------------------------
function ok=all_strings(c)
% Check elements of a cell array are 1xn non-empty character strings
ok=true;
for i=1:numel(c)
    ok=ischar(c{i}) && ~isempty(c{i}) && size(c{i},1)==1;
end
