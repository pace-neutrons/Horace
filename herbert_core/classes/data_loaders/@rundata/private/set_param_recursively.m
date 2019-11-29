function this=set_param_recursively(this,a_struct,varargin)
% function to fill the rundata class from data, defined in the input
% structure,class or their combinations
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%
if isempty(a_struct)
    return;
end

if isa(a_struct,'rundata')
    this = a_struct;
    if numel(varargin) == 0
        return;
    end
    if isstruct(varargin{1})
        this=set_param_recursively(this,varargin{1},varargin{2:end});
    else
        this=parse_arg(this,varargin{:});        
    end
elseif isstruct(a_struct)
    field_names    = fieldnames(a_struct);
    targ_fields    = fieldnames(this);
    field_values   = cell(numel(field_names),1);
    for i=1:numel(field_names)
        field_values{i} = a_struct.(field_names{i});
    end
    this=set_fields_skip_special(this,field_names,field_values,targ_fields);
    if numel(varargin)>0
        this = set_param_recursively(this,varargin{1},varargin{2:end});
    end
else
    argi = [a_struct,varargin];
    this=parse_arg(this,argi{:});
end

function this= parse_arg(this,varargin)
% function processes arguments, which are present in varargin as
% couple of 'key','value' parameters or as a structure 
% and sets correspondent fields in the input data_structure
% 
% usage:
%>> result = parse_arg(source,'a',10,'b','something')
%
%                 source -- structure or class with public fields a and b
%                 result   -- the same structure as source with 
%                 result.a==10 and result.b=='something'
%   
% throws error if field a and b are not present in source
% usage:
%>> result = parse_arg(template,source)
%                similar to above but fields a and b with correspondent
%                values are set in structure source e.g.

% Parse arguments;
narg = length(varargin);
if narg==0; return; end;

[field_nams,field_vals] = parse_config_arg(varargin{:});
valid = ~cellfun('isempty',field_vals);
field_nams=field_nams(valid);
field_vals=field_vals(valid);
target_fields = fieldnames(this);

this = set_fields_skip_special(this,field_nams,field_vals,target_fields);

%----------------------------------------------------------------------------------------
function [field_nams,field_vals] = parse_config_arg(varargin)
% Process arguments, which are present in varargin as a number of 'key','value' pairs
% or as a structure, and returns two output cell arrays of fields and values.
% 
%   >> [field_nams,field_vals] = parse_config_arg('a',10,'b','something')
%
%   >> [field_nams,field_vals] = parse_config_arg(source)
%                             Similar to above but fields a and b with corresponding
%                             values are set in structure source e.g.
%                             source.a==10 and source.b=='something'

% Parse arguments;
narg = length(varargin);
if narg==0; return; end;

if narg==1
    svar = varargin{1};
    is_struct = isa(svar,'struct');
    is_cell   = iscell(svar);
    if ~(is_struct || is_cell)
        error('PARSE_CONFIG_ARG:wrong_arguments','input parameter has to be a structure or a cell array');       
    end
    if is_struct
        field_nams = fieldnames(svar)';
        field_vals = cell(1,numel(field_nams));
        for i=1:numel(field_nams)
            field_vals{i}=svar.(field_nams{i});
        end        
    end
    if is_cell
        field_nams = svar(1:2:end);
        field_vals = svar(2:2:end);
    end
else
    if (rem(narg,2) ~= 0)
         error('PARSE_CONFIG_ARG:wrong_arguments','incomplete set of (field,value) pairs given');        
    end
    field_nams = varargin(1:2:narg);
    field_vals = varargin(2:2:narg);
        
end

function this=set_fields_skip_special(this,field_names,field_values,target_fields)
% set rundata fields to the values specified checking if such fields exist
% and are the special fields which redefine loader
%
file_name = '';
par_file_name = '';
loader_redefined = false;
for i=1:numel(field_names)
    cur_field = field_names{i};
    
    if strcmp(cur_field,'file_name') || strcmp(cur_field,'data_file_name')
        file_name = field_values{i};
        loader_redefined=true;
        continue
    end
    if strcmp(cur_field,'par_file_name')
        par_file_name = field_values{i};
        loader_redefined=true;
        continue
    end
    
    if ~ismember(cur_field,target_fields)
        if ismember(cur_field,oriented_lattice.lattice_fields())
            this = set_lattice_field(this,cur_field,field_values{i});
            continue
        else
            error('RUNDATA:set_fields','Attempt to set non-existing field: %s',cur_field);
        end
    end
    
    if ~isempty(field_names{i}) 
        this.(field_names{i})=field_values{i};
    end
end
if loader_redefined
    if isempty(this.loader__)
        this=select_loader(this,file_name,par_file_name);
    else
        if isempty(file_name)
            this.loader__.par_file_name = par_file_name;
        else
            this.loader__ = loaders_factory.instance().get_loader(file_name,par_file_name);
        end
    end
end

