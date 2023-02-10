function pix_out = mask(obj, mask_array, npix)
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
    error('HORACE:PixelDataMemory:invalid_argument', ...
        ['Bad number of output arguments.\n''mask'' must be ' ...
        'called with exactly one output argument.']);
end

if ~exist('npix', 'var')
    npix = [];
end

[mask_array, npix] = validate_input_args(obj, mask_array, npix);

if numel(mask_array) == obj.num_pixels && all(mask_array)
    pix_out = obj;
    return;
elseif numel(mask_array) == obj.num_pixels && ~any(mask_array)
    pix_out = PixelDataBase.create();
    return;
end

if numel(mask_array) == obj.num_pixels

    pix_out = obj.get_pixels(mask_array);

elseif ~isempty(npix)

    full_mask_array = repelem(mask_array, npix);
    pix_out = obj.get_pixels(full_mask_array);

end

end


function [mask_array, npix] = validate_input_args(obj, mask_array, npix)
parser = inputParser();
parser.addRequired('obj');
parser.addRequired('mask_array');
parser.addOptional('npix', []);
parser.parse(obj, mask_array, npix);

mask_array = parser.Results.mask_array;
npix = parser.Results.npix;

if numel(mask_array) ~= obj.num_pixels && isempty(npix)
    error('HORACE:PixelDataMemory:invalid_argument', ...
        ['Error masking pixel data.\nThe input mask_array must have ' ...
        'number of elements equal to the number of pixels or must ' ...
        ' be accompanied by the npix argument. Found ''%i'' ' ...
        'elements, ''%i'' or ''%i'' elements required.'], ...
        numel(mask_array), obj.num_pixels, obj.page_size);
elseif ~isempty(npix)
    if any(numel(npix) ~= numel(mask_array))
        error('HORACE:PixelDataMemory:invalid_argument', ...
            ['Number of elements in mask_array and npix must be equal.' ...
            '\nFound %i and %i elements'], numel(mask_array), numel(npix));
    elseif sum(npix(:)) ~= obj.num_pixels
        error('HORACE:PixelDataMemory:invalid_argument', ...
            ['The sum of npix must be equal to number of pixels.\n' ...
            'Found sum(npix) = %i, %i pixels required.'], ...
            sum(npix(:)), obj.num_pixels);
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
