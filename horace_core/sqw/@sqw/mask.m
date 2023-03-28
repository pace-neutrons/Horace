function wout = mask (win, mask_array)
% Remove the bins indicated by the mask array
%
%   >> wout = mask (win, mask_array)
%
% Input:
% ------
%   win                 Input sqw object
%
%   mask_array          Array of 1 or 0 (or true or false) that indicate
%                      which points to retain (true to retain, false to ignore)
%                       Numeric or logical array of same number of elements
%                      as the data_.
%                       Note: mask will be applied to the stored data array
%                      according as the projection axes, not the display axes.
%                      Thus permuting the display axes does not alter the
%                      effect of masking the data_.
%
% Output:
% -------
%   wout                Output dataset.
%
% Original author: T.G.Perring
%

% Initialise output argument
% if win.has_pixels()
%     wout = copy(win, 'exclude_pix', true);  % pixels will be assigned later
% else
wout = copy(win);
% end

% Trivial case of empty or no mask arguments
if nargin==1 || isempty(mask_array)
    return
end

[wout.data,mask_array] = mask(wout.data,mask_array);

% Section the pix array, if non empty, and update pix_range
if has_pixels(win)
    if wout.pix.is_filebacked
        wout = wout.get_new_handle();
    end
    wout.pix = wout.pix.mask(mask_array, win.data.npix);
end
