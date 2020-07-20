function new_sqw = copy(obj)
% Copy this SQW object or an array of sqw objects
%
% As PixelData is a handle class, we must call the copy operator on the pixels
% so the two SQW objects do not point to the same pixel data
new_sqw = obj;
for i = 1:numel(obj)
    if is_sqw_type(obj(i))
        new_sqw(i).data.pix = copy(obj(i).data.pix);
    end
end
