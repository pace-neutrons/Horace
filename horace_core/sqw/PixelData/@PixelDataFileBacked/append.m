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

if ~obj.tmp_io_handler_.has_tmp_file_
    pix_out.dump_all_pixels_();
end

pix.move_to_page(1);
pix_out.tmp_io_handler_ = pix_out.tmp_io_handler_.append_pixels(pix.data());


while pix.has_more()
    pix.advance();
    pix_out.tmp_io_handler_ = pix_out.tmp_io_handler_.append_pixels(pix.data());
end

new_range = [min(pix.pix_range(1,:),pix_out.pix_range(1,:));...
             max(pix.pix_range(2,:),pix_out.pix_range(2,:))];

pix_out.num_pixels_ = pix_out.num_pixels_ + pix.num_pixels;
pix_out.set_range(new_range);
pix_out.reset_changed_coord_range('coordinates');
pix_out.page_edited = true;

end