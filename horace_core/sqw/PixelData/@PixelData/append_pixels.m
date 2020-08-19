function obj = append_pixels(obj, pix)
% Join the pixels in the given PixelData object to the end of this
% object
%
% Input
% -----
% pix    A PixelData object containing the pixels to append
%
if ~isa(pix, 'PixelData')
    error('PIXELDATA:append_pixels', ...
            'Input object must be of class ''PixelData''. Found ''%s''', ...
            class(pix));
end
if isempty(pix)
    return;
end
if pix.num_pixels > obj.max_page_size_
    error('PIXELDATA:append_pixels', ...
            ['Cannot append more pixels than allowed in a single page\n ' ...
            'Found ''%i'' pixels, ''%i'' allowed.'], pix.num_pixels, ...
            obj.max_page_size_);
end

if ~(obj.get_num_pages_() == obj.page_number_)
    if obj.page_is_dirty_(obj.page_number_) && obj.dirty_page_edited_
        obj.write_dirty_page_();
    end
    obj.load_page_(obj.get_num_pages_());
end

if isempty(obj)
    obj.data_ = pix.data;
    obj.set_page_dirty_(true);
else
    if obj.page_size < obj.max_page_size_
        num_to_allocate_to_pg = obj.max_page_size_ - obj.page_size;
        obj.data_ = horzcat(obj.data, pix.data(:, 1:num_to_allocate_to_pg));
        obj.set_page_dirty_(true);

        if num_to_allocate_to_pg ~= pix.num_pixels
            obj.write_dirty_page_();

            obj.data_ = pix.data(:, (num_to_allocate_to_pg + 1):end);
            obj.page_number_ = obj.page_number_ + 1;
        end

    elseif obj.page_size == obj.max_page_size_
        obj.set_page_dirty_(true);
        if obj.dirty_page_edited_
            obj.write_dirty_page_();
        end
        obj.data_ = pix.data;
        obj.page_number_ = obj.page_number_ + 1;
    end
end

obj.num_pixels_ = obj.num_pixels_ + pix.num_pixels;
obj.set_page_dirty_(true);
