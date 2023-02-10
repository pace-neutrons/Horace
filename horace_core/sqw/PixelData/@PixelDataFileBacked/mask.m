function pix_out = mask(obj, mask_array, varargin)
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
% pix_out      A PixelData object containing only non-masked pixels.
%
if nargout ~= 1
    error('PIXELDATA:mask', ['Bad number of output arguments.\n''mask'' must be ' ...
        'called with exactly one output argument.']);
end

[mask_array, npix] = validate_input_args(obj, mask_array, varargin{:});

if numel(mask_array) == obj.num_pixels && all(mask_array)
    pix_out = obj;
    return;
elseif numel(mask_array) == obj.num_pixels && ~any(mask_array)
    pix_out = PixelDataBase.create();
    return;
end

if numel(mask_array) == obj.num_pixels

    pix_out = do_mask_file_backed_with_full_mask_array(obj, mask_array);

elseif ~isempty(npix)

    pix_out = do_mask_file_backed_with_npix(obj, mask_array, npix);

end

end

function pix_out = do_mask_file_backed_with_full_mask_array(obj, mask_array)
% Perfrom a mask of a file-backed PixelData object with a mask array as
% long as the full PixelData array i.e. numel(mask_array) == pix.num_pixels
%

pix_out = PixelDataFileBacked();
fid = pix_out.get_new_handle();

for i = 1:obj.n_pages
    obj.load_page(i);
    [start_idx, end_idx] = obj.get_page_idx_(i);
    mask_array_chunk = mask_array(start_idx:end_idx);

    fwrite(fid, obj.data(:, mask_array_chunk), obj.FILE_DATA_FORMAT_);

end

pix_out.num_pixels_ = sum(mask_array);
pix_out.finalise(fid);

end

function pix_out = do_mask_file_backed_with_npix(obj, mask_array, npix)
% Perform a mask of a file-backed PixelData object with a mask array and
% an npix array. The npix array should account for the full range of pixels
% in the PixelData instance i.e. sum(npix) == pix.num_pixels.
%
% The mask_array and npix array should have equal dimensions.
%

pix_out = PixelDataFileBacked();
% Re #928 filebacked masking shoule be completed there
%fid = pix_out.get_new_handle();
error('HORACE:mask:not_implemented','Filebacked masking is not currently implemented Re #928')
[npix_chunks, idxs] = split_vector_fixed_sum(npix(:), obj.base_page_size);
pix_out.num_pixels_ = 0;

for i = 1:obj.n_pages
    npix_for_page = npix_chunks{i};
    idx = idxs(:, i);

    obj.page_num = i;
    mask_array_chunk = repelem(mask_array(idx(1):idx(2)), npix_for_page);

    pix_out.num_pixels_ = pix_out.num_pixels + sum(mask_array_chunk);

 %   fwrite(fid, obj.data(:, mask_array_chunk), obj.FILE_DATA_FORMAT_);

end

%pix_out.finalise(fid);

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
    error('PIXELDATA:mask', ...
        ['Error masking pixel data.\nThe input mask_array must have ' ...
        'number of elements equal to the number of pixels or must ' ...
        ' be accompanied by the npix argument. Found ''%i'' ' ...
        'elements, ''%i'' or ''%i'' elements required.'], ...
        numel(mask_array), obj.num_pixels, obj.page_size);
elseif ~isempty(npix)
    if any(numel(npix) ~= numel(mask_array))
        error('PIXELDATA:mask', ...
            ['Number of elements in mask_array and npix must be equal.' ...
            '\nFound %i and %i elements'], numel(mask_array), numel(npix));
    elseif sum(npix, 'all') ~= obj.num_pixels
        error('PIXELDATA:mask', ...
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
