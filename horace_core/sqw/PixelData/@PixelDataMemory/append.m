function pix_out = append(obj, pix)
% Join the pixels in the given PixelData object to the end of this
% object.
%
% Input
% -----
% pix    A PixelData object containing the pixels to append
%

pix_out = obj;

if ~isa(pix, 'PixelDataBase')
    error('HORACE:PixelDataMemory:invalid_argument', ...
        'Input object must be subclass of ''PixelDataBase''. Found ''%s''', ...
        class(pix));
end

if isempty(pix)
    return;
end

for i = 1:pix.num_pages
    pix.page_num = i;
    pix_out.data_ = horzcat(pix_out.data, pix.data);
end

end
