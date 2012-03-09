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
% $Revision$ ($Date$)
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
