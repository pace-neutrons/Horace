function [s,e,npix,pix] = sort_pixels_by_bins(obj,pix,varargin)
% Bin pixels into 4D grid, defined by aProjection
%
% in a future, this function should use pix class, which has its
% own range
%
%
% $Revision: 1471 $ ($Date: 2017-04-24 10:26:58 +0100 (Mon, 24 Apr 2017) $)
%

if nargin>2
    pix_range = varargin{1};
else
    pix_range = [];
end
[s,e,npix,pix] = sort_pixels_by_bins_(obj,pix,pix_range);
