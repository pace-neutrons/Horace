function pix_cc = transform_spher_to_pix_(obj,pix_data)
% Transform pixels expressed in image coordinate coordinate systems
% into crystal Cartesian coordinate system
%
% Input:
% pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
%             expressed in spherical coordinate system
% Returns
% pix_cc -- pixels coordinates expressed in Crystal Cartesian coordinate
%           system

ndim = size(pix_data,1);
%Original arrangement :  pix_transf = [r;pi/2- elevation;azimuth];
%Requested arrangement:  [x,y,z] = sph2cart(azimuth,elevation,r);
[x,y,z] = sph2cart(pix_data(3,:),pi/2-pix_data(2,:),pix_data(1,:));

[rot_to_img,offset]=obj.get_pix_img_transformation(ndim);

%
if ndim == 3
    pix_cc= (bsxfun(@plus,[x;y;z]'/rot_to_img',offset))';
else
    pix_cc= (bsxfun(@plus,[x;y;z;pix_data(4,:)]'/rot_to_img',offset))';    
end


