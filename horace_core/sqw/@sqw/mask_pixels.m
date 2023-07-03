function wout = mask_pixels (win, keep_info)
% Remove the pixels indicated by the mask array
%
% Note: mask will be applied to the stored data array
% according as the projection axes, not the display axes.
% Thus permuting the display axes does not alter the
% effect of masking the data.
%
%   >> wout = mask_pixels (win, keep_info)    % Mask array
%
% Input:
% ------
%   win                Input sqw object
%
%   keep_info          Array of 1 or 0 (or true or false) that indicate
%                      which pixels to retain (true to retain, false to ignore)
%                      Numeric or logical array of same number of pixels
%                      as the data.
%    *OR*
%                      sqw object in which the signal in individual pixels is
%                      interpreted as a mask array:
%                           =1 (or true)  to retain
%                           =0 (or false) to remove
%                      the sqw object must have the same dimensionality, number of bins
%                      along each dimension, and number of pixels in each bins
%                      as the object to be masked.
%
% Output:
% -------
%   wout                Output dataset.

% Original author: T.G.Perring

% Check object to be masked is an sqw-type object
if ~has_pixels(win)
    error('HORACE:sqw:invalid_argument', ...
        'Can mask pixels only in an sqw-type object')
end

% Initialise output argument
wout = copy(win);

% Trivial case of empty or no mask arguments
if ~exist('keep_info', 'var') || isempty(keep_info)
    return
end

% Check mask is OK
[nd,sz] = dimensions(win);
if numel(sz) == 1
    sz = [sz, 1];
end

if isa(keep_info, 'SQWDnDBase')
    if ~has_pixels(keep_info)
        error('HORACE:sqw:invalid_argument', ...
              'If the mask object is a Horace object if must be sqw-type i.e. contain pixel information')
    end

    [nd_msk, sz_msk] = dimensions(keep_info);

    if numel(sz_msk) == 1
        sz_msk = [sz_msk, 1];
    end

    if (~isequal(nd, nd_msk) || ...
        ~isequal(sz, sz_msk) || ...
        ~isequal(win.data.npix,keep_info.data.npix))
        error('HORACE:sqw:invalid_argument', ...
              'Dimensionality, number of bins on each dimension and number of pixels in each bin of input and mask must match')
    end

    keep_info=logical(keep_info.pix.signal);

elseif (isnumeric(keep_info) || islogical(keep_info)) && ...
        numel(keep_info)~=numel(win.data.s)

    if ~islogical(keep_info)
        keep_info=logical(keep_info);
    end

else
    error('HORACE:sqw:invalid_argument', ...
          'Mask must provide a numeric or logical array with same number of elements as the data or an SQW with the same projection and axes')
end

% Section the pix array, if sqw type, and update pix_range and img_range(s)
% (linear) bin number for each pixel
ibin = replicate_array(1:prod(sz), win.data.npix);
npix = accumarray(ibin(keep_info), ones(1, sum(keep_info)), [prod(sz), 1]);

wout.data.npix = reshape(npix, sz);

wout = wout.get_new_handle();
wout.pix = wout.pix.mask(keep_info);

wout = recompute_bin_data(wout);

end
