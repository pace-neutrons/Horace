function [subobj,new_subobj] = extract_correct_subobj_(obj,obj_name,varargin)
% Extract a subobject, requested for save, calculate positions or upgrade operations
% using various parts of sqw object, or the requested part provided directly
%
% $Revision$ ($Date$)
%
char_keys = cellfun(@(x)strncmp(x,'-',1),varargin);
argi = varargin(~char_keys);
if ~isempty(argi) 
    input_obj = argi{1};
    type = class(input_obj);
    if isa(input_obj,'sqw')
        subobj = input_obj.(obj_name);
    elseif strcmp(type,obj_name) || isstruct(input_obj) % the requested object provided directly
        subobj = input_obj;
    else
        error('SQW_FILE_IO:invalid_argument',...
            'SQW_BINFILE_COMMON::extract_correct_subobj: Requested to extract subobject %s  but can get only %s',...
            obj_name,type);
    end
    new_subobj = true;
else % mast be an sqw object:
    subobj = obj.sqw_holder_.(obj_name);
    new_subobj = false;
end

