function wout = mask_random_fraction_pixels(win,npix_frac)
% reduce the number of pixels randomly in a sqw object
%
% The function uses the mask_pixels() function to keep only a fixed
% fraction of pixels randomly chosen. Useful when doing numerically intensive
% simulations of sqw objects with sqw_eval or fit_sqw, to speed things up
%
% wout = mask_random_fraction_pixels(win,npix_frac)
%
% Input:
% ------
%   win                 Input sqw object
%
%   npix_frac           Fraction of pixels in win.pix array to keep.
%                       These are chosen at random. If win is an array then
%                       npix can either be a scalar, in which case all
%                       outputs will have the same number of retained
%                       pixels, or an array of the same size as win, in
%                       which case each mask is applied separately.
% Output:
% -------
%   wout                Output dataset.

% Original author: S. Toth
% Modifications: R. A. Ewings


%Check size of input array:
sz=numel(win);

if ~(numel(npix_frac)==1 || numel(npix_frac)==numel(win))
    error('HORACE:sqw:invalid_argument', ...
        'npix must either be scalar or an array of the same size as input sqw object');
end
if numel(npix_frac) == 1 && numel(win)>1
    npix_frac = ones(1,numel(win))*npix_frac;
end

npix = zeros(1,sz);
for i=1:sz
    if npix_frac(i) <=0
        error('HORACE:sqw:invalid_argument', ...
            'Cannot mask every pixel, or have negative fraction of pixels retained');
    elseif npix_frac(i) >1
        error('HORACE:sqw:invalid_argument', ...
            'Can not have pixel fraction larger then 1')
    end
    npix(i) = round(win(i).num_pixels*npix_frac(i));
    if npix(i)<1
        npix(i) = 1;
    end
end

wout = mask_random_pixels(win,npix);
