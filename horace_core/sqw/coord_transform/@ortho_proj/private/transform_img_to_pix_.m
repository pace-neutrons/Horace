function pix_cc = transform_img_to_pix_(obj,pix_data)
% Transform pixels expressed in image coordinate coordinate systems
% into crystal Cartesian coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal image coordinate system (mainly hkl)
% Returns
% pix_cc -- pixels coordinates expressed in Crystal Cartesian coordinate
%           system

ndim = size(pix_data,1);
[rot_to_img,shift]=obj.get_pix_img_transformation(ndim);
%
pix_cc= (bsxfun(@plus,pix_data'/rot_to_img',shift'))';

