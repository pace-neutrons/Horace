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

pixels = false(size(w));
for i=1:numel(w)
    if w(i).data.pix.num_pixels > 0
        pixels(i) = true;
    else
        pixels(i) = false;
    end
end

