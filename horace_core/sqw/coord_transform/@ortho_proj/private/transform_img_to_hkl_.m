function pix_hkl = transform_img_to_hkl_(obj,pix_data)
% Transform pixels expressed in image coordinate coordinate systems
% into crystal Cartesian coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal image coordinate system (e.g. hkl)
% Returns
% pix_cc -- pixels coordinates expressed in Crystal Cartesian coordinate
%           system

ndim = size(pix_data,1);
[rot_to_img,offset]=obj.get_pix_img_transformation(ndim);
bmat = obj.bmatrix();
if ndim == 4
    bmat = [[bmat;zeros(1,3)],[0;0;0;1]];
end
rot_to_img = bmat*rot_to_img;
%
pix_hkl= (bsxfun(@plus,rot_to_img\pix_data,offset(:)));
