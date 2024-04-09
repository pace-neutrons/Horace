function pix_cc = transform_cylinder_to_pix_(obj,pix_data)
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
[rot_to_img,offset_cc,scales,offset_present]=obj.get_pix_img_transformation(ndim);

%Original arrangement :  
% [phi,rho,z] = cart2pol(pix_transf(1,:),pix_transf(2,:),pix_transf(3,:))
% pix_transf = [cales(1)*rho; scales(2)*z; scales(3)*phi]
%Requested arrangement:  [x,y,z] = pol2cart(phi,rho,z);
[x,y,z] = pol2cart(pix_data(3,:)/scales(3),pix_data(1,:)/scales(1),pix_data(2,:)/scales(2));

%
if ndim == 3
    if offset_present
        pix_cc= bsxfun(@plus,rot_to_img\[x;y;z],offset_cc(:));
    else
        pix_cc= rot_to_img\[x;y;z];
    end
else
    if offset_present
        pix_cc= bsxfun(@plus,rot_to_img\[x;y;z;pix_data(4,:)],offset_cc(:));
    else
        pix_cc= rot_to_img\[x;y;z;pix_data(4,:)];
    end
end
