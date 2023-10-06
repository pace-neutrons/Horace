function obj = mask (obj, keep_array)
% Remove the bins indicated by the mask array
%
%   >> wout = mask (win, keep_array)
%
% Input:
% ------
%   obj                Input sqw object
%
%   keep_array         Array of 1 or 0 (or true or false) that indicate
%                      which points to retain (true to retain, false to ignore)
%                      Numeric or logical array of same number of elements
%                      in the sqw.data.npix array.
%                       Note: mask will be applied to the stored data array
%                      according as the projection axes, not the display axes.
%                      Thus permuting the display axes does not alter the
%                      effect of masking the data.
%
% Output:
% -------
%   obj                Modified sqw object.
%
% Original author: T.G.Perring
%


% Trivial case of empty or no mask arguments
if nargin==1 || isempty(keep_array)
    return
end

% Section the pix array, if non empty, and update pix_range
if has_pixels(obj)
    obj = obj.mask_pixels(obj,keep_array,true);
else
    % mask appropriate data
    obj.data = mask(obj.data,keep_array);
end
