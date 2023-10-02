function wout = mask_random_pixels(obj,npix)
% reduce the number of pixels randomly in a sqw object
%
% The function uses the mask_pixels() function to keep only a fixed amount
% of randomly chosen pixels. Useful when doing numerically intensive
% simulations of sqw objects with sqw_eval or fit_sqw, to speed things up
%
% wout = mask_random_pixels(win,npix)
%
% Input:
% ------
%   win                 Input sqw object
%
%   npix                Number of pixels in win.pix array to keep.
%                       The kept pixels are chosen at random.
%                       npix can either be a scalar, in which case all
%                       outputs will have the same number of retained
%                       pixels, or an array of the same size as win,
%                       in which case each output will have the
%                       respective number of retained pixels.
% Output:
% -------
%   wout                Output dataset.

% Original author: S. Toth
% Modifications: R. A. Ewings

if ~has_pixels(obj)
    error('HORACE:sqw:invalid_argument', ...
        'Can not mask random pixels on sqw object not containing any pixels')
end

wout = obj;
sz = numel(obj);

npix = round(npix);
if isscalar(npix)
    npix = repmat(npix, sz, 1);
end

if numel(npix) ~= numel(obj)
    error('HORACE:sqw:invalid_argument', ...
        'npix must either be scalar or an array of the same size as input sqw object');
end

if any(npix == 0)
    error('HORACE:sqw:invalid_argument', ...
        'Cannot mask every pixel');
end
invalid = arrayfun(@(i)(obj(i).pix.num_pixels>npix(i)),1:sz);
if any(invalid)
    error('HORACE:sqw:invalid_argument', ...
        'Cannot retain greater number of pixels than data contains');
end

for i=1:sz
    % reduce the number of pixels using mask
    wout(i) = mask_pixels(obj(i),npix(i));
end
