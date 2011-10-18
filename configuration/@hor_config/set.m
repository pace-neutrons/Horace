function conf=set(this,varargin)
%
%    var = set(config,var, 'field1', val1, 'field2, val2, ... )
%    var = set(config, struct_val )
%    var = set(config, cellarray) where the cell array has the form {'field1',val1,...,etc.} 
%
%    var = set(config,'defaults')
%
% function sets corespondent fields in the Horace configuration
% it also writes the resutling structure into configuration file for future
% usage;
% the last form sets up the configuration to its default values, e.g. the
% one, specified in the config structure
%
% $Revision$ ($Date$)
%
global configurations;
global class_names;

% Parse arguments;
[field_nams,field_vals] = parse_config_arg(varargin{:});

nf = numel(field_nams);

% check argumemts
non_char = ~cellfun(@is_data_char,field_nams);
if (any(non_char))
    mess='all field_names has to be strings';    
    error('HORACE:config',mess);
end
% get access to the internal structure

config_data      = struct(this);
config_fields    = fieldnames(config_data);
class_name                = class(this);
class_place               = ismember(class_names,class_name);


sealed_fields=ismember(config_data.fields_sealed,field_nams);
if any(sealed_fields);    
    mess='some field values requested are sealed and can not be set manually';
    error('HORACE:config',mess);
end

% the name of this variable has to coinside with the name defined in
% constructor as both fucntions has to save the same data in the same place
member_fields    = ismember(config_fields,field_nams);
if sum(member_fields)~=nf
    non_member = ~ismember(field_nams,config_fields);
    non_m_fields=field_nams(non_member);
    
    error('CONFIG:set','configuration class: %s does not have fields you are trying to set, namely: %s %s %s %s %s %s %s %s ',...
    class_name,non_m_fields{:});   
end

%
% if we mofifying the parent class, all childrens hav to be modified too as
% we inherit from the parent by value;
if strcmp(class_name,class_names{1}) % very ugly way of doing things but very complicated algorighm otherwise;
    clear global configurations;
    clear global class_names;  
    class_names{1}=class_name;
else % we should not write the parent structure into the data file
    config_data=rmfield(config_data,class_names{1});
end


% set the fields
for i=1:nf
    this.(field_nams{i})       =field_vals{i}; % in memory 
    config_data.(field_nams{i})=field_vals{i}; % and in file on HDD
end
    
configurations{class_place}=this;
conf = configurations{class_place};

% save data into the correspondent configuration file;
config_file_path= config_folder(config);
config_file_name= class_name;
config_file = fullfile(config_file_path,config_file_name);
save(config_file,'config_data')

function rez=is_data_char(data)
rez=isa(data,'char');

