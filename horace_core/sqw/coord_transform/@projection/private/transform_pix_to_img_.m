function pix_transf = transform_pix_to_img_(obj,pix_cc,varargin)
% Transform pixels expressed in crystal Cartesian coordinate systems
% into image coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in crystal Cartesian coordinate system
% Returns:
% pix_transformed -- the pixels transformed into coordinate
%             system, related to image (often hkl system)
%

ndim = size(pix_cc,1);
if isempty(obj.projaxes_)
    pix_transf  = pix_cc;
else
    [rot_to_img,shift]=obj.get_pix_img_transformation(ndim);
    %
    pix_transf= ((bsxfun(@minus,pix_cc,shift))'*rot_to_img')';
end
