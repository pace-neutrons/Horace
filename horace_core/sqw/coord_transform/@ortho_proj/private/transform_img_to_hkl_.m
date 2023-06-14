function pix_hkl = transform_img_to_hkl_(obj,pix_data)
% Transform pixels expressed in image coordinate system
% into hkl(dE) coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in image coordinate system (e.g. rotated hkl)
% Returns
% pix_hkl -- pixels coordinates in physical hkl(dE) coordinate system


ndim = size(pix_data,1);
[rot_to_img,offset]=obj.get_pix_img_transformation(ndim);
bmat = obj.bmatrix();
if ndim == 4
    bmat = [[bmat;zeros(1,3)],[0;0;0;1]];
end
hkl_tansf = bmat*rot_to_img;
%
pix_hkl= (bsxfun(@plus,hkl_tansf\pix_data,offset(:)));
