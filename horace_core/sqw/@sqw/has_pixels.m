function pixels = has_pixels(w)
% Determine if the SQW object has pixeldata
%
%   >> sqw_type = has_pixels(w)
%
% Input:
% ------
%   w           sqw object or array of objects
%
% Output:
% -------
%   pixels    =true or =false (array)

pixels = arrayfun(@(x) x.data.pix.num_pixels > 0, w);
