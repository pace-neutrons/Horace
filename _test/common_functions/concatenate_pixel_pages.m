function data = concatenate_pixel_pages(pix)
%% CONCATENATE_PIXEL_PAGES concatenate the pages of a PixelData object into
% a single array of data. This returns a raw MATLAB array, not a PixelData
% object
%
pix = pix.move_to_first_page();
base_pg_size = pix.page_size;
num_cols_in_pix_block = size(pix.data, 1);

data = zeros(num_cols_in_pix_block, pix.num_pixels);
iter = 0;

for i=1:pix.num_pages
    pix.page_num = i;
    start_idx = (iter*base_pg_size) + 1;
    end_idx = min(start_idx + base_pg_size - 1, pix.num_pixels);
    data(:, start_idx:end_idx) = pix.data;
    iter = iter + 1;
end
pix = pix.move_to_first_page();
