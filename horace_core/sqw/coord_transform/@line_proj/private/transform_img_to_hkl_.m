function pix_hkl = transform_img_to_hkl_(obj,img_data)
% Transform pixels expressed in image coordinate system
% into hkl(dE) coordinate system
%
% Input:
% img_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in image coordinate system (e.g. rotated and scaled hkl)
% Returns
% pix_hkl -- pixels coordinates in physical hkl(dE) coordinate system


ndim = size(img_data,1);
[q_to_img,offset_cc]=obj.get_pix_img_transformation(ndim);

if ndim == 4
    bmat = obj.bmatrix(4);
else
    bmat = obj.bmatrix();
end
hkl_to_img = q_to_img*bmat;
offset = bmat\offset_cc;
%
pix_hkl= (bsxfun(@plus,hkl_to_img\img_data,offset(:)));
