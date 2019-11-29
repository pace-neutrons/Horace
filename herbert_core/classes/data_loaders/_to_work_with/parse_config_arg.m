function [ field_nams,field_vals] = parse_config_arg(varargin)
% function processes arguments, which are present in varargin as
% couple of 'key',value parameters or as a structure 
% and sets correspondent fiels in data_struct
% 
% usage:
%>> result = parce_arg(source,'a',10,'b','something')
%
%                 source -- structure or class with public fields a and b
%                 result   -- the same structure as source with 
%                 result.a==10 and result.b=='something'
%   
% throws error if field a and b are not present in source
% Similar usage:
%>> result = parce_arg(template,source)
%                similar to above but fields a and b with correspondent
%                values are set in structure source e.g.
%                source.a==10 and source.b=='something'
%

% Parse arguments;
narg = length(varargin);
if narg==0; return; end;

if narg==1
    svar = varargin{1};
    is_struct = isa(svar,'struct');
    is_cell   = iscell(svar);
    if ~(is_struct || is_cell)
        error('PARSE_ARG:wrong_arguments','second parameter has to be a structure or a cell array');       
    end
    if is_struct
        field_nams = fieldnames(svar);
        field_vals = cell(1,numel(field_nams));
        for i=1:numel(field_nams)
            field_vals{i}=svar.(field_nams{i});
        end        
    end
    if is_cell
        field_nams  = {svar{1:2:end}};
        field_vals     = {svar{2:2:end}};        
    end
else
    if (rem(narg,2) ~= 0)
         error('PARSE_ARG:wrong_arguments','incomplete set of (field,value) pairs given');        
    end
    field_nams = {varargin{1:2:narg}};
    field_vals   ={varargin{2:2:narg}};
        
end


