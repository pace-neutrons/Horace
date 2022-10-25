function has = has_pixels(w)
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
%   has    =true or =false (array)

has = arrayfun(@(x) x.pix.num_pixels > 0, w);
