function [subobj,subobj_is_new] = extract_correct_subobj_(obj,obj_name,varargin)
% Extract a subobject, requested for save, calculate positions or upgrade operations
% using various parts of sqw object, or the requested part provided directly
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%
char_keys = cellfun(@is_char_key,varargin);
argi = varargin(~char_keys);
if ~isempty(argi)
    input_obj = argi{1};
    subobj_is_new = true;
else
    input_obj = obj.sqw_holder_;
    subobj_is_new = false;
    if isempty(input_obj)
        subobj = [];
        return
    end
end
%

if isa(input_obj,'sqw') || is_sqw_struct(input_obj)
    subobj = input_obj.(obj_name);
elseif  isstruct(input_obj)|| isa(input_obj,'is_holder')  % the requested object provided directly
    subobj = input_obj;  % and is one of the supported types
elseif strcmp(obj_name,'data') || isa(input_obj,'data_sqw_dnd')
    subobj = input_obj; 
elseif strcmp(obj_name,'header') || iscell(input_obj)
    subobj = input_obj; %
else
    type = class(input_obj);    
    error('SQW_FILE_IO:invalid_argument',...
        'SQW_BINFILE_COMMON::extract_correct_subobj: Requested to extract subobject %s  but can get only %s',...
        obj_name,type);
end

function is = is_char_key(x)
if ischar(x)
    is = strncmp(x,'-',1);
else
    is = false;
end

