function data = concatenate_pixel_pages(pix)
%% CONCATENATE_PIXEL_PAGES concatenate the pages of a PixelData object into
% a single array of data. This returns a raw Matlab array, not a PixelData
% object
%
data = pix.get_fields('all', 'all');

end
