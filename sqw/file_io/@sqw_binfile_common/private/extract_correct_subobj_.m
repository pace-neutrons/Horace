function [subobj,new_subobj] = extract_correct_subobj_(obj,obj_name,varargin)
% Extract a subobject, requested for save or upgrade operations, using
% various input arguments combinations
%
%
new_subobj = false;
if ~isempty(varargin)
    input_obj = varargin{1};
    type = class(input_obj);
    if isa(input_obj,'sqw')
        subobj = input_obj.(obj_name);
    elseif strcmp(type,obj_name) || isstruct(input_obj) % the requested object provided directrly
        subobj = input_obj;
    else
        error('SQW_BINFILE_COMMON:invalid_argument',...
            'put_detinfo: the routine accepts an sqw object and/or "-update" options only');
    end
    new_subobj = true;
else % mast be sqw object
    subobj = obj.sqw_holder_.(obj_name);
end

