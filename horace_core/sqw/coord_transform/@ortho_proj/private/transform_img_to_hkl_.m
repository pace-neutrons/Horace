function pix_hkl = transform_img_to_hkl_(obj,img_data)
% Transform pixels expressed in image coordinate system
% into hkl(dE) coordinate system
%
% Input:
% img_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in image coordinate system (e.g. rotated hkl)
% Returns
% pix_hkl -- pixels coordinates in physical hkl(dE) coordinate system


ndim = size(img_data,1);
[rot_to_img,offset]=obj.get_pix_img_transformation(ndim);

if ndim == 4
    bmat = obj.bmatrix(4);
else
    bmat = obj.bmatrix();
end
hkl_tansf = bmat*rot_to_img;
%
pix_hkl= (bsxfun(@plus,hkl_tansf\img_data,offset(:)));
