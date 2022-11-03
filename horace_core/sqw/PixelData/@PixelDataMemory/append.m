function pix_out = append(obj, pix)
% Join the pixels in the given PixelData object to the end of this
% object.
%
% The pixels to append must all be in memory and you cannot append pixels if
% the inputted PixelData object has more pixels than are allowed in a single
% page.
%
% Input
% -----
% pix    A PixelData object containing the pixels to append
%
if nargout == 1
    pix_out = copy(obj);
else
    pix_out = obj;
end

if ~isa(pix, 'PixelDataBase')
    error('PIXELDATA:append:invalid_argument', ...
        'Input object must be subclass of ''PixelDataBase''. Found ''%s''', ...
        class(pix));
end

if isempty(pix)
    return;
end

pix.move_to_first_page();
while true

    pix_out.data_ = horzcat(pix_out.data, pix.data);

    if pix_out.has_more()
        pix_out.advance();
    else
        break;
    end
end

pix_out.reset_changed_coord_range('coordinates');
pix_out.num_pixels_ = pix_out.num_pixels_ + pix.num_pixels;

end
