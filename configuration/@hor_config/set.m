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
narg = length(varargin);
if narg==1
    svar = varargin{1};
    if ischar(svar)&&strcmpi(svar,'defaults')
        class_name = class(this);
        set_defaults(config,class_name);
        return;
    end
    is_struct = isa(svar,'struct');
    is_cell   = iscell(svar);
    if ~is_struct ||(~is_cell)
        mess='set->second parameter has to be a structure or a cell array';
        error('CONFIG:set',mess);
        
    end
    if is_struct
        field_nams = fieldnames(svar);
        field_vals = zeros(1,numel(field_nams));
        for i=1:numel(field_nams)
            field_vals(i)=svar.(field_nams{i});
        end        
    end
    if is_cell
        field_nams  = svar{1:2:end};
        field_vals  = svar{2:2:end};        
    end
 
else
   if (rem(narg,2) ~= 0)
        mess='set->Incomplete set of (field,value) pairs given';
        error('CONFIG:set',mess);        
   end
   field_nams = varargin{1:2:narg};
   field_vals  =varargin{2:2:narg};
   if ~iscell(field_vals)
       field_vals={field_vals};
   end
   if ~iscell(field_nams)
        field_nams={field_nams};
   end   
   
   nf = narg/2;
%   field_nams = cell(1,nf);
%   field_vals = zeros(1,nf);   
%   for i=0:nf-1
%       field_nams{i+1}=varargin{2*i+1};
%       field_vals(i+1)=varargin{2*i+2};       
%   end
        
end

% check argumemts
non_char = ~cellfun(@is_data_char,field_nams);
if (any(non_char))
    mess='all field_names has to be strings';    
    error('CONFIG:set',mess);
end
% get access to the internal structure

config_data      = struct(this);
config_fields    = fieldnames(config_data);


sealed_fields=ismember(config_data.fields_sealed,field_nams);
if any(sealed_fields);    
    mess='some field values requested are sealed and can not be set manually';
    error('CONFIG:set',mess);
end

class_name                = class(this);
class_place               = ismember(class_names,class_name);
% the name of this variable has to coinside with the name defined in
% constructor as both fucntions has to save the same data in the same place
member_fields    = ismember(config_fields,field_nams);
if sum(member_fields)~=nf    
    error('CONFIG:set','set->Some parameters specified but do not exist in the configuration class: %s ',class_name);
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

