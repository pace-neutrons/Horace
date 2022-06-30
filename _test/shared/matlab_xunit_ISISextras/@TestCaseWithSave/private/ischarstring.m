function tf = ischarstring (x)
% Determine if a variable is non-empty character string
%
%   >> ok = ischarstring (x)


tf = (ischar(x) && numel(size(x))==2 && size(x,1)==1 && size(x,2)>0);
