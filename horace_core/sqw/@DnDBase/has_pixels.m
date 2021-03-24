function pixels = has_pixels(w)
% Determine if the DnD object has pixeldata: this is _always_ false
%
%   >> pix = has_pixels(w)
%
% Input:
% ------
%   w           DnD object or array of objects
%
% Output:
% -------
%   pixels    =false (array)

pixels = repmat(false, size(w));