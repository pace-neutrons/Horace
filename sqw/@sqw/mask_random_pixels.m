function wout = mask_random_pixels(win,npix)
% reduce the number of pixels randomly in a sqw object
%
% The function uses the mask_pixels() function to keep only a fixed amount
% of pixels randomly chosen. Useful when doing numerically intensive
% simulations of sqw objects with sqw_eval or fit_sqw, to speed things up
%
% wout = mask_random_pixels(win,npix)
%
% Input:
% ------
%   win                 Input sqw object
%
%   npix               Number of pixels in win.data.pix array to keep.
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

if ~is_sqw_type(win);
    error('Can mask pixels only in an sqw-type object')
end

% Initialise output argument
wout = win;


%Check size of input array:
sz=numel(win);

if ~(numel(npix)==1 || numel(npix)==numel(win))
    error('npix must either be scalar or an array of the same size as input sqw object');
end

for i=1:sz
    if numel(npix)==1
        %Trivial case when npix==0:
        if npix==0
            error('Cannot mask every pixel');
        end

        %If non integer npix, round to nearest integer:
        if round(npix)~=npix
            npix=round(npix);
        end
        nn=npix;
    else
        %Trivial case when npix==0:
        if npix(i)==0
            error('Cannot mask every pixel');
        end

        %If non integer npix, round to nearest integer:
        if round(npix(i))~=npix(i)
            npix(i)=round(npix(i));
        end
        nn=npix(i);
    end
    
    %Error if npix>= total number pixels:
    if nn>=size(win(i).data.pix,2)
        error('Cannot retain greater number of pixels than data contains');
    end
    % reuce the number of pixels using mask
    mask0 = false([1 size(win(i).data.pix,2)]);
    mask0(randperm(size(win(i).data.pix,2),nn)) = true;
    wout(i) = mask_pixels(win(i),mask0);
end

end