function pix_cc = transform_img_to_pix_(obj,pix_data)
% Transform pixels expressed in image coordinate coordinate systems
% into crystal cartezian coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal image coordinate systed (mainly hkl)
% Returns
% pix_cc -- pixels coordinates expressed in Crystal Cartesian coordinate
%           system

ndim = size(pix_data,1);
if isempty(obj.projaxes_)
    pix_cc  = pix_data;
else
    [rot_to_img,shift]=obj.get_pix_img_transformation(ndim);
    %
    pix_cc= ((bsxfun(@plus,pix_data,shift))'/(rot_to_img'))';
end
