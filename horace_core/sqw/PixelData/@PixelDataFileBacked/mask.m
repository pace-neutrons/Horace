function obj = mask(obj, keep_array, varargin)
% MASK retains only the pixels specified by the input logical array
%
% You must specify exactly one return argument when calling this function.
%
% Input:
% ------
% keep_array   A logical array specifying which pixels should be kept/removed
%              from the PixelData object. Must be of length equal to the number
%              of pixels in 'obj' or equal in size to the 'npix' argument. A
%              true/1 in the array indicates that the pixel at that index
%              should be retained, a false/0 indicates the pixel should be
%              removed.
%
% npix         (Optional)
%              Array of integers that specify how many times each value in
%              mask_array should be replicated. This is useful for when masking
%              all pixels contributing to a bin. Size must be equal to that of
%              'keep_array'. E.g.:
%               keep_array = [      0,     1,     1,  0,     1]
%               npix       = [      3,     2,     2,  1,     2]
%               full_mask  = [0, 0, 0,  1, 1,  1, 1,  0,  1, 1]
%
%              The npix array must account for all pixels in the PixelData
%              object i.e. sum(npix, 'all') == obj.num_pixels. It must also be
%              the same dimensions as 'keep_array' i.e.
%              all(size(keep_array) == size(npix)).
%
% Output:
% -------
% obj      A PixelData object containing only non-masked pixels.
%
%
[keep_array, npix] = obj.validate_input_args_for_mask(keep_array, varargin{:});

if ~any(keep_array)
    obj = PixelDataBase.create();
elseif numel(keep_array) == obj.num_pixels %all specified
    obj = do_mask_file_backed_with_full_mask_array(obj, keep_array);
else
    obj = do_mask_file_backed_with_npix(obj, keep_array, npix);
end

end

function obj = do_mask_file_backed_with_full_mask_array(obj, keep_array)
% Perfrom a mask of a file-backed PixelData object with a mask array as
% long as the full PixelData array i.e. numel(mask_array) == pix.num_pixels
%

obj = obj.ready_dump();
keep_array = logical(keep_array);

mem_chunk_size = obj.default_page_size;
obj.data_range = obj.EMPTY_RANGE;

curr = 1;
page = 1;
npix = obj.num_pixels;
for i = 1:mem_chunk_size:npix
    obj.page_num = page;
    block_size = min(mem_chunk_size,npix-i+1);
    page_keep = keep_array(i:i+block_size-1);
    data = obj.data(:,page_keep);

    block_size= size(data,2);

    obj.format_dump_data(data, curr);
    obj.data_range = ...
        obj.pix_minmax_ranges(data, obj.data_range);

    curr = curr + block_size;
    page = page+1;
end

obj = obj.finalise(sum(keep_array));

end

function obj_out = do_mask_file_backed_with_npix(obj, keep_array, npix)
% Perform a mask of a file-backed PixelData object with a mask array and
% an npix array. The npix array should account for the full range of pixels
% in the PixelData instance i.e. sum(npix) == pix.num_pixels.
%
% The mask_array and npix array should have equal dimensions.
%

obj_out = obj;
if obj_out.is_misaligned
    obj_out.alignment_matr = [];
end

obj_out = obj_out.ready_dump();

keep_array = logical(keep_array);

[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.default_page_size);
obj_out.data_range = obj.EMPTY_RANGE;

curr = 1;
npg = obj.num_pages;
for i = 1:npg
    obj.page_num = i;
    npix_for_page = npix_chunks{i};
    idx = idxs(:, i);
    pixmask_array_chunk = repelem(keep_array(idx(1):idx(2)), npix_for_page);

    data = obj.data(:, pixmask_array_chunk);

    if isempty(data)
        continue;
    end

    obj_out.data_range = obj_out.pix_minmax_ranges(data, ...
        obj_out.data_range);

    obj_out.format_dump_data(data, curr);

    curr = curr + size(data,2);
end

obj_out.num_pixels_ = sum(npix(:) .* keep_array(:), 'all');
obj_out = obj_out.finalise();

end
