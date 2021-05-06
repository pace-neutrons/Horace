function wout = mask_pixels (win, mask_array)
% Remove the pixels indicated by the mask array
%
%   >> wout = mask_pixels (win, mask_array)     % Mask array
%   >> wout = mask_pixels (win, wmask)          % Mask according to pixel array
%                                               % contents
%
% Input:
% ------
%   win                 Input sqw object
%
%   mask_array          Array of 1 or 0 (or true or false) that indicate
%                      which pixels to retain (true to retain, false to ignore)
%                       Numeric or logical array of same number of pixels
%                      as the data.
%                       Note: mask will be applied to the stored data array
%                      according as the projection axes, not the display axes.
%                      Thus permuting the display axes does not alter the
%                      effect of masking the data.
%    *OR*
%   wmask               sqw object in which the signal in individual pixels is
%                      interpreted as a mask array:
%                           =1 (or true)  to retain
%                           =0 (or false) to remove
%                       wmask must have the same dimensionality, number of bins
%                      along each dimension, and number of pixels in each bins
%                      as the array to be masked.
%
% Output:
% -------
%   wout                Output dataset.


% Original author: T.G.Perring
%



% Check object to be masked is an sqw-type object
if ~has_pixels(win)
    error('Can mask pixels only in an sqw-type object')
end

% Initialise output argument
wout = copy(win);

% Trivial case of empty or no mask arguments
if nargin==1 || isempty(mask_array)
    return
end

% Check mask is OK
[nd,sz]=dimensions(win);
if numel(sz)==1
    sz=[sz,1];
end

if isa(mask_array, 'SQWDnDBase')
    if has_pixels(mask_array)
        [nd_msk,sz_msk]=dimensions(mask_array);
        if numel(sz_msk)==1
            sz_msk=[sz_msk,1];
        end
        if isequal(nd,nd_msk) && isequal(sz,sz_msk) && isequal(win.data_.npix,mask_array.data_.npix)
            mask_array=logical(mask_array.data_.pix.signal);
        else
            error('Dimensionality, number of bins on each dimension and number of pixels in each bin of input and mask must match')
        end
    else
        error('If the mask object is a Horace object if must be sqw-type i.e. contain pixel information')
    end
elseif (isnumeric(mask_array) || islogical(mask_array)) && numel(mask_array)~=numel(win.data_.s)
    if ~islogical(mask_array)
        mask_array=logical(mask_array);
    end
else
    error('Mask must provide a numeric or logical array with same number of elements as the data')
end

% Section the pix array, if sqw type, and update pix_range and img_db_range(s)
ibin = replicate_array(1:prod(sz),win.data_.npix);   % (linear) bin number for each pixel
npix=accumarray(ibin(mask_array),ones(1,sum(mask_array)),[prod(sz),1]);
wout.data_.npix=reshape(npix,sz);
wout.data_.pix=win.data_.pix.mask(mask_array);
wout=recompute_bin_data(wout);
