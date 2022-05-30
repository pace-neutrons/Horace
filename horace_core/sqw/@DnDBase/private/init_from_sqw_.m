function obj = init_from_sqw_(obj, sqw_obj)
% Populate DnD class data from an SQW object.
%
% An error is raised if the SQW object does not match the
% dimensions of the DnD
sqw_dim = sqw_obj.dimensions();
if sqw_dim ~= obj.NUM_DIMS
    error('HORACE:DnDBase:invalid_argument', ...
        ['SQW object with %d dimensions cannot be converted to a %d-dimensional dnd-type object.\n',...
        ' Use cut to reduce the dimensionality of sqw object'],...
        sqw_dim,obj.NUM_DIMS);
end
obj.data_ = sqw_obj.data;
obj.data_.pix = PixelData();
