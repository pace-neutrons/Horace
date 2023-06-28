function obj = mask(obj, mask_array, varargin)
% MASK remove the pixels specified by the input logical array
%
% You must specify exactly one return argument when calling this function.
%
% Input:
% ------
% mask_array   A logical array specifying which pixels should be kept/removed
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
%              'mask_array'. E.g.:
%               mask_array = [      0,     1,     1,  0,     1]
%               npix       = [      3,     2,     2,  1,     2]
%               full_mask  = [0, 0, 0,  1, 1,  1, 1,  0,  1, 1]
%
%              The npix array must account for all pixels in the PixelData
%              object i.e. sum(npix, 'all') == obj.num_pixels. It must also be
%              the same dimensions as 'mask_array' i.e.
%              all(size(mask_array) == size(npix)).
%
% Output:
% -------
% obj      A PixelData object containing only non-masked pixels.
%
[mask_array, npix] = validate_input_args(obj, mask_array, varargin{:});

if ~any(mask_array)
    obj = PixelDataBase.create();
elseif numel(mask_array) == obj.num_pixels %all specified
    obj = do_mask_file_backed_with_full_mask_array(obj, mask_array);

else
    obj = do_mask_file_backed_with_npix(obj, mask_array, npix);
end

end

function obj = do_mask_file_backed_with_full_mask_array(obj, mask_array)
% Perfrom a mask of a file-backed PixelData object with a mask array as
% long as the full PixelData array i.e. numel(mask_array) == pix.num_pixels
%

if isempty(obj.file_handle_)
    obj = obj.get_new_handle();
end

mask_array = obj.logical_to_normal_index_(mask_array);
obj.num_pixels_ = numel(mask_array);

mem_chunk_size = obj.default_page_size;
obj.data_range = obj.EMPTY_RANGE;

curr = 1;
for i = 1:mem_chunk_size:obj.num_pixels
    block_size = min(obj.num_pixels - i + 1, mem_chunk_size);
    data = obj.get_fields('all', mask_array(i:i+block_size));

    obj.format_dump_data(data, curr);
    obj.data_range = ...
        obj.pix_minmax_ranges(data, obj.data_range);

    curr = curr + block_size;
end

obj = obj.finalise();

end

function obj_out = do_mask_file_backed_with_npix(obj, mask_array, npix)
% Perform a mask of a file-backed PixelData object with a mask array and
% an npix array. The npix array should account for the full range of pixels
% in the PixelData instance i.e. sum(npix) == pix.num_pixels.
%
% The mask_array and npix array should have equal dimensions.
%

obj_out = obj;

if isempty(obj_out.file_handle_)
    obj_out = obj_out.get_new_handle();
end

[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.default_page_size);
obj_out.num_pixels_ = sum(npix .* mask_array, 'all');
obj_out.data_range = obj.EMPTY_RANGE;

curr = 1;
npg = obj.num_pages;
for i = 1:npg
    obj.page_num = i;
    data = obj.data;
    npix_for_page = npix_chunks{i};
    idx = idxs(:, i);

    mask_array_chunk = repelem(mask_array(idx(1):idx(2)), npix_for_page);

    data = data(:, mask_array_chunk);

    obj_out.data_range = obj_out.pix_minmax_ranges(data, ...
        obj_out.data_range);

    obj_out.format_dump_data(data, curr);

    curr = curr + sum(mask_array_chunk);
end

obj_out = obj_out.finalise();

end

function [mask_array, npix] = validate_input_args(obj, mask_array, varargin)
parser = inputParser();
parser.addRequired('obj');
parser.addRequired('mask_array');
parser.addOptional('npix', []);
parser.parse(obj, mask_array, varargin{:});

mask_array = parser.Results.mask_array;
npix = parser.Results.npix;

if numel(mask_array) ~= obj.num_pixels && isempty(npix)
    error('HORACE:mask:invalid_argument', ...
        ['Error masking pixel data.\nThe input mask_array must have ' ...
        'number of elements equal to the number of pixels or must ' ...
        ' be accompanied by the npix argument. Found ''%i'' ' ...
        'elements, ''%i'' or ''%i'' elements required.'], ...
        numel(mask_array), obj.num_pixels, obj.page_size);

elseif ~isempty(npix)
    if any(numel(npix) ~= numel(mask_array))
        error('HORACE:mask:invalid_argument', ...
            ['Number of elements in mask_array and npix must be equal.\n' ...
            'Found %i and %i elements'], numel(mask_array), numel(npix));
    elseif sum(npix, 'all') ~= obj.num_pixels
        error('HORACE:mask:invalid_argument', ...
            ['The sum of npix must be equal to number of pixels.\n' ...
            'Found sum(npix) = %i, %i pixels required.'], ...
            sum(npix, 'all'), obj.num_pixels);
    end
end

if ~isvector(mask_array)
    mask_array = mask_array(:);
end

if ~isa(mask_array, 'logical')
    mask_array = logical(mask_array);
end

if ~isempty(npix) && ~isvector(npix)
    npix = npix(:);
end

end
