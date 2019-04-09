function [data_struct,field_nams,field_vals] = parse_arg(data_struct,varargin)
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
% $Author: Alex Buts; 20/10/2011
%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
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
    error('PARSE_ARG:wrong_arguments',err);        
end

for i=1:numel(field_vals)
    data_struct.(field_nams{i})=field_vals{i};
end

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
