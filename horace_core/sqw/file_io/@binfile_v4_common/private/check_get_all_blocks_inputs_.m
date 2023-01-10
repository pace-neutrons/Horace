function [obj,obj_to_set,is_serializable] = check_get_all_blocks_inputs_(obj,varargin)
% retrieve sqw/dnd object from hdd and return its values in
% the object provided as input.
% Inputs:
% obj             -- initialized instance of faccessor
% Optional:
% filename_or_obj
% Either       -- name of the file to initialize faccessor
%                 from if the object have not been initialized
%                 before
% OR           -- the object to modify with the data,
%                 obtained using initialized faccessor
% obj_to_set   -- if provided, previous parameter have to be
%                 the file to read data from. Then this
%                 parameter defines the object, to modify the
%                 data using faccessor, initialized by file
%                 above
% if none of additinal parameters is specified, result is
% returned in sqw object
% Output:
% obj          -- initialized instance of faccessor.
% obj_to_set   -- the object, modified by the contents,
%                 obtained from the file. If other objects are
%                 not specified as input, this object is sqw
%                 object.


obj_to_set =[];
if nargin > 1
    filename_or_obj = varargin{1};
    if ischar(filename_or_obj)||isstring(filename_or_obj)
        obj = obj.init(filename_or_obj);
    else
        obj_to_set = filename_or_obj;
    end
end
if nargin>2
    if ~isempty(obj_to_set)
        error('HORACE:binfile_v4_common:invalid_argument', ...
            'Two input parameters identified as object to modify and return. First has class: %s and second class: %s', ...
            class(varargin{1}),class(varargin{2}))
    end
    obj_to_set = varargin{2};
elseif isempty(obj_to_set)
    obj_to_set = sqw();
end
if isa(obj_to_set,'serializable')
    is_serializable = true;
    obj_to_set.do_check_combo_arg = false;
else
    is_serializable = false;
end
