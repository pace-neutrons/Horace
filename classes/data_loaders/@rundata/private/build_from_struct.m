function this=build_from_struct(this,a_struct,varargin)
% function to fill the rundata class from data, defined in the input
% structure,class or their combinations
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
%

if isempty(a_struct)
    return;
end

if isa(a_struct,'rundata')
    this = a_struct;
    if isstruct(varargin{1})
        this=build_from_struct(this,varargin{1},varargin{2:end});
    else
        this=parse_arg(this,varargin{:});        
    end
elseif isstruct(a_struct)
    field_names    = fieldnames(a_struct);
    present_fields = fieldnames(this);
    if ~any(ismember(field_names,present_fields))
        error('RUNDATA:build_from_struct',' attempting to set field %s but such field does not exist in run_data class\n',set_fields{ismember(set_fields,present_fields)});
    end
    field_values = cell(numel(field_names),1);
    for i=1:numel(field_names)
        field_values{i} = a_struct.(field_names{i});
    end
    this=set_fields_skip_special(this,field_names,field_values);
    
    this = build_from_struct(this,varargin{1},varargin{2:end});
else
    argi = {a_struct,varargin{:}};
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
%                source.a==10 and source.b=='something'
%
%
%

% Parse arguments;
narg = length(varargin);
if narg==0; return; end;

[field_nams,field_vals] = parse_config_arg(varargin{:});
valid = ~cellfun('isempty',field_vals);
field_nams=field_nams(valid);
field_vals=field_vals(valid);

target_fields = fieldnames(data_struct);
if ~all(ismember(field_nams,target_fields))
    miss = ~ismember(field_nams,target_fields);
    err=sprintf('parse_arg: field %s do not exist in target structue\n',field_nams{miss});
    error('RUNDATA:parse_arg',err);        
end
this = set_fields_skip_special(this,field_nams,field_vals);

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
        error('PARSE_CONFIG_ARG:wrong_arguments','second parameter has to be a structure or a cell array');       
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

function this=set_fields_skip_special(this,field_names,field_values)

file_name = '';
par_file_name = '';
loader_redefined = false;
for i=1:numel(field_names)
    if strcmp(field_names{i},'file_name')
        file_name = field_values{i};
        loader_redefined=true;
    end
    if strcmp(field_names{i},'par_file_name')
        par_file_name = field_values{i};
        loader_redefined=true;
    end
    
    if ~isempty(field_names{i}) 
        this.(field_names{i})=field_values{i};
    end
end
if loader_redefined
    if isempty(file_name)
        this.loader.par_file_name = par_file_name;
    else
        this.loader = loaders_factory.instance().get_loader(file_name,par_file_name);
    end
end

