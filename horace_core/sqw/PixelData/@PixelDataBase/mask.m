function obj = mask(obj, keep_array, npix)
% MASK keeps only pixels specified by the input logical array
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
% pix_out      A PixelData object containing only non-masked pixels.
%
if nargout ~= 1
    error('HORACE:PixelDataBase:invalid_argument', ...
        ['Bad number of output arguments.\n''mask'' must be ' ...
        'called with exactly one output argument.']);
end

if ~exist('npix', 'var')
    npix = [];
end

[keep_array, npix] = validate_input_args_for_mask_(obj, keep_array, npix);

if all(keep_array)
    return
elseif ~any(keep_array)
    obj = PixelDataBase.create();
    return;
elseif numel(keep_array) == obj.num_pixels % all specified
    keep = keep_array;
elseif ~isempty(npix) && sum(npix) == obj.num_pixels
    keep = keep_array;
else
    error('HORACE:PixelDataBase:invalid_argument', ...    
        'keep array size must be either equal to num_pixels in PixelData (%d) or number of elements in npix array provided (%d). It is: %d', ...
        obj.num_pixels,sum(npix(:)),numel(keep_array));
end
pix_op = PageOp_mask();
if ~isempty(npix)
    pix_op.npix = npix;
end
[pix_op,obj] = pix_op.init(obj,keep);
obj    = obj.apply_c(obj,pix_op);


