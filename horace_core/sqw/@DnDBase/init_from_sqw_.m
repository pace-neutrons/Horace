function obj = init_from_sqw_(obj, sqw_obj)
% Populate DnD class data from an SQW object.
%
% An error is raised if the SQW object does not match the
% dimensions of the DnD
sqw_dim = sqw_obj.dimensions();
if sqw_dim ~= obj.NUM_DIMS
    error([upper(class(obj)), ':' class(obj)], ...
        ['SQW object cannot be converted to a ' num2str(obj.NUM_DIMS) 'd dnd-type object']);
end
obj.data_ = sqw_obj.data;
end
