function wout = mask_pixels (win, keep_obj)
% Remove the pixels indicated by the mask array
%
%   >> wout = mask_pixels (win, keep_obj)     % Mask array
%   >> wout = mask_pixels (win, wmask)        % Mask according to pixel array
%                                             % contents
%
% Input:
% ------
%   win                 Input sqw object
%
%   keep_obj          Array of 1 or 0 (or true or false) that indicate
%                      which pixels to retain (true to retain, false to ignore)
%                      Numeric or logical array of same number of pixels
%                      as the data.
%                      Note: mask will be applied to the stored data array
%                      according as the projection axes, not the display axes.
%                      Thus permuting the display axes does not alter the
%                      effect of masking the data.
%    *OR*
%   wmask              sqw object in which the signal in individual pixels is
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
    error('HORACE:sqw:invalid_argument', ...
        'Can mask pixels only in an sqw-type object')
end

% Initialise output argument
wout = copy(win);

% Trivial case of empty or no mask arguments
if nargin==1 || isempty(keep_obj)
    return
end

% Check mask is OK
[nd,sz]=dimensions(win);
if numel(sz)==1
    sz=[sz,1];
end

if isa(keep_obj, 'SQWDnDBase')
    if has_pixels(keep_obj)
        [nd_msk,sz_msk]=dimensions(keep_obj);
        if numel(sz_msk)==1
            sz_msk=[sz_msk,1];
        end
        if isequal(nd,nd_msk) && isequal(sz,sz_msk) && isequal(win.data.npix,keep_obj.data.npix)
            keep_obj=logical(keep_obj.pix.signal);
        else
            error('HORACE:sqw:invalid_argument', ...
                'Dimensionality, number of bins on each dimension and number of pixels in each bin of input and mask must match')
        end
    else
        error('HORACE:sqw:invalid_argument', ...
            'If the mask object is a Horace object if must be sqw-type i.e. contain pixel information')
    end
elseif (isnumeric(keep_obj) || islogical(keep_obj)) && numel(keep_obj)~=numel(win.data.s)
    if ~islogical(keep_obj)
        keep_obj=logical(keep_obj);
    end
else
    error('HORACE:sqw:invalid_argument', ...
        'Mask must provide a numeric or logical array with same number of elements as the data')
end

% Section the pix array, if sqw type, and update pix_range and img_range(s)
ibin = replicate_array(1:prod(sz),win.data.npix);   % (linear) bin number for each pixel
npix=accumarray(ibin(keep_obj),ones(1,sum(keep_obj)),[prod(sz),1]);
wout.data.npix=reshape(npix,sz);
wout = wout.get_new_handle();
wout.pix=win.pix.mask(keep_obj);
wout=recompute_bin_data(wout);
