function pix_cc = transform_img_to_pix_(obj,pix_data)
% Transform pixels expressed in image coordinate system
% into crystal Cartesian coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of image coordinates
%             expressed in image coordinate system (e.g. hkl or rotated hkl)
% Returns
% pix_cc -- pixels coordinates expressed in Crystal Cartesian coordinate
%           system

ndim = size(pix_data,1);
[pix_to_img,offset]=obj.get_pix_img_transformation(ndim);
% transposed pix_to_image transformation, as the transformation is defined
% as column vectors and pixel_data here are also column vectors.
pix_cc= (bsxfun(@plus,pix_to_img\pix_data,offset(:)));
