function [wout,mask_array] = mask (win, mask_array)
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
wout = win;

% Trivial case of empty or no mask arguments
if nargin==1 || isempty(mask_array)
    return
end

% Check mask is OK
if ~(isnumeric(mask_array) || islogical(mask_array)) || numel(mask_array) ~= numel(win.s)
    error('HORACE:DnDBase:mask', ...
        ['Mask must provide a numeric or logical array with ' ...
        'same number of elements as the image data']);
end
if ~islogical(mask_array)
    mask_array=logical(mask_array);
end

% Mask signal, variance and npix arrays
wout.s_(~mask_array) = 0;
wout.e_(~mask_array) = 0;
wout.npix_(~mask_array) = 0;

