function c = smooth_func_hat(width)
% Fills a matrix with a hat function in multiple dimensions.
% Output matrix normalised so sum of elements = 1
%
% Syntax:
%   >> c = smooth_func_hat(width)
%
%   width   Vector containing full-width half-height (FWHH) of hat function in pixels
%           along each dimension. Rounded to nearest value to FWHH=1,3,5.... .
%               e.g. in 1D, width = 1.9 treated as 1; 2.1 treated as 3
%           FWHH=0 is treated as FWHH=1 i.e. no convolution
%
%   c       Convolution array

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring

if length(width)==1
    c = ones([max(1,2*floor(width/2)+1),1]);
else
    c = ones(max(1,2*floor(width/2)+1));
end
c = c/sum(reshape(c,1,numel(c)));
