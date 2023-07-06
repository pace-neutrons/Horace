function [keep_array, npix] = validate_input_args_for_mask_(obj, keep_array, npix)
% check input arguments for masking routines
% Inputs:
% obj        -- an instance of PixelDataBase object
% keep_array -- logical array specifying which pixels to keep
% Optional:
% npix       -- if present, array specifying number of pixels
%               contriburing to each bin of DnD object image.
% If npix is absent or empty, keep_array size should be equal
% to number of pixels and if present, numel(keep_array(:)) ==
% numel(npix(:));


persistent parser
if isempty(parser)
    parser = inputParser();
    parser.addRequired('obj');
    parser.addRequired('keep_array');
    parser.addOptional('npix', []);
end
parser.parse(obj, keep_array, npix);

keep_array = parser.Results.keep_array(:);
npix = parser.Results.npix;

if numel(keep_array) ~= obj.num_pixels && isempty(npix)
    error('HORACE:PixelDataMemory:invalid_argument', ...
        ['Error masking pixel data.\nThe input mask_array must have ' ...
        'number of elements equal to the number of pixels or must ' ...
        ' be accompanied by the npix argument. Found ''%i'' ' ...
        'elements, ''%i'' or ''%i'' elements required.'], ...
        numel(keep_array), obj.num_pixels, obj.page_size);
elseif ~isempty(npix)
    if any(numel(npix) ~= numel(keep_array))
        error('HORACE:PixelDataMemory:invalid_argument', ...
            ['Number of elements in mask_array and npix must be equal.' ...
            '\nFound %i and %i elements'], numel(keep_array), numel(npix));
    elseif sum(npix(:)) ~= obj.num_pixels
        error('HORACE:PixelDataMemory:invalid_argument', ...
            ['The sum of npix must be equal to number of pixels.\n' ...
            'Found sum(npix) = %i, %i pixels required.'], ...
            sum(npix(:)), obj.num_pixels);
    end
end

if ~isa(keep_array, 'logical')
    keep_array = logical(keep_array);
end

if ~isempty(npix) && ~isvector(npix)
    npix = npix(:);
end
