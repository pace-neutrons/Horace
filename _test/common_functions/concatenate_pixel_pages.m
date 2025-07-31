function data = concatenate_pixel_pages(pix)
%% CONCATENATE_PIXEL_PAGES concatenate the pages of a PixelData object into
% a single array of data. This returns a raw MATLAB array, not a PixelData
% object
%
pix = pix.move_to_first_page();

num_cols_in_pix_block = size(pix.data, 1);

data = zeros(num_cols_in_pix_block, pix.num_pixels);

start_idx = 1;
for i=1:pix.num_pages
    pix.page_num = i;
    page_size = pix.page_size;
    
    end_idx = min(start_idx + page_size - 1, pix.num_pixels);
    data(:, start_idx:end_idx) = pix.data;
    start_idx = end_idx + 1;
end
%pix = pix.move_to_first_page();
