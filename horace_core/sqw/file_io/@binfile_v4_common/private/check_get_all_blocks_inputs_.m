function [obj,obj_to_set,is_serializable,ignored_blocks_list] = check_get_all_blocks_inputs_(obj,varargin)
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
% 'ignore_blocks'     ! the keyword which identifies that some blocks
%                     ! should not be loaded
% list of block names ! following the the first keyword the list of block
%                     ! banes to ignore

% if none of additinal parameters is specified, result is
% returned in sqw object
% Output:
% obj          -- initialized instance of faccessor.
% obj_to_set   -- the object, modified by the contents,
%                 obtained from the file. If other objects are
%                 not specified as input, this object is sqw
%                 object.
% is_serializable
%             -- true if obj_to_set is the child of serializable
% ignored_blocks_list
%             -- if 'ignore_blocks' keyword is provided, list of the block
%                names to skip in save/loading operations
%                empty if 
%           


obj_to_set =[];
[ignored_blocks_list,argi] = extract_ignored_blocks_arg_(varargin{:});

inarg = numel(argi);
if inarg > 0
    filename_or_obj = argi{1};
    if ischar(filename_or_obj)||isstring(filename_or_obj)
        obj = obj.init(filename_or_obj);
    else
        obj_to_set = filename_or_obj;
    end
end
if inarg >1
    if ~isempty(obj_to_set)
        error('HORACE:binfile_v4_common:invalid_argument', ...
            'Two input parameters identified as object to modify and return. First has class: %s and second class: %s', ...
            class(argi{1}),class(argi{2}))
    end
    obj_to_set = argi{2};
elseif isempty(obj_to_set)
    cln = class(obj);
    if contains(cln,'dnd')
        obj_to_set = d0d();
    else
        obj_to_set = sqw();        
    end
end
if isa(obj_to_set,'serializable')
    is_serializable = true;
    obj_to_set.do_check_combo_arg = false;
else
    is_serializable = false;
end
