function [s,e,npix,pix,pix_range] = sort_pixels_by_bins(obj,pix_coord,varargin)
% Bin pixels expressed in orthogonal coordinate system into 4D grid,
% defined by aProjection
%
% in a future, this function should use pix class, which has its
% own range
%
%
% $Revision: 1471 $ ($Date: 2017-04-24 10:26:58 +0100 (Mon, 24 Apr 2017) $)
%

if nargin>2
    pix_img_range = obj.calc_image_range(varargin{1});
else
    pix_img_range = [];
end
%
pix_img = obj.pix_to_img(pix_coord);
%
[s,e,npix,pix,pix_range] = sort_pixels_by_bins_(obj,pix_coord,pix_img,pix_img_range);
