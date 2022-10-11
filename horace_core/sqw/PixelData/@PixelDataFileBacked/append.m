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

if ~isa(pix, 'PixelData')
    error('PIXELDATA:append', ...
        'Input object must be of class ''PixelData''. Found ''%s''', ...
        class(pix));
end
if isempty(pix)
    return;
end

if pix.num_pixels > pix_out.base_page_size
    error('PIXELDATA:append', ...
        ['Cannot append more pixels than allowed in a single page.\n ' ...
        'Found ''%i'' pixels, ''%i'' allowed.'], pix.num_pixels, ...
        pix_out.base_page_size);
elseif pix.get_num_pages_() > 1
    error('PIXELDATA:append', ...
        ['Cannot append pixels from a PixelData object with more than one page.\n ' ...
        'Found ''%i'' pages.'], pix.get_num_pages_());
end

if ~(pix_out.get_num_pages_() == pix_out.page_number_)
    if pix_out.page_is_dirty_(pix_out.page_number_) && pix_out.dirty_page_edited_
        pix_out.write_dirty_page_();
    end
    pix_out.load_page_(pix_out.get_num_pages_());
end

if isempty(pix_out)
    pix_out.data_ = pix.data;
    pix_out.set_page_dirty_(true);
    pix_out.reset_changed_coord_range('coordinates');
elseif pix_out.page_size < pix_out.base_page_size
    num_to_allocate_to_pg = min(pix_out.base_page_size - pix_out.page_size, ...
        pix.num_pixels);
    pix_out.data_ = horzcat(pix_out.data, pix.data(:, 1:num_to_allocate_to_pg));
    pix_out.reset_changed_coord_range('coordinates');
    glob_range = pix_out.pix_range;
    pix_out.set_page_dirty_(true);
    if num_to_allocate_to_pg ~= pix.num_pixels
        pix_out.write_dirty_page_();

        pix_out.data_ = pix.data(:, (num_to_allocate_to_pg + 1):end);
        %
        pix_out.reset_changed_coord_range('coordinates');
        loc_range = pix_out.page_range;
        glob_range = [min(glob_range(1,:),loc_range(1,:));...
            max(glob_range(2,:),loc_range(2,:))];
        %
        pix_out.page_number_ = pix_out.page_number_ + 1;
        pix_out.set_page_dirty_(true);
    end
    pix_out.set_range(glob_range);

elseif pix_out.page_size == pix_out.base_page_size
    glob_range = pix_out.pix_range;
    if ~pix_out.is_filebacked()
        % If data is not file-backed the exisiting data must be saved to a tmp
        % file after page is changed - so mark it dirty
        pix_out.set_page_dirty_(true);
    end
    if pix_out.dirty_page_edited_
        pix_out.write_dirty_page_();
    end
    pix_out.data_ = pix.data;
    pix_out.reset_changed_coord_range('coordinates');
    loc_range = pix_out.pix_range;
    pix_out.page_number_ = pix_out.page_number_ + 1;
    pix_out.set_page_dirty_(true);
    glob_range = [min(glob_range(1,:),loc_range(1,:));...
        max(glob_range(2,:),loc_range(2,:))];
    pix_out.set_range(glob_range);
end
%

%
pix_out.num_pixels_ = pix_out.num_pixels_ + pix.num_pixels;
