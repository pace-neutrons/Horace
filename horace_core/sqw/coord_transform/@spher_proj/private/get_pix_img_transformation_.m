function [rot_to_img,offset,theta_to_ang,phi_to_ang]=get_pix_img_transformation_(obj,ndim)
% Return the constants and parameters used for transformation
% from Crystal Cartezian to spherical coordinate system and
% back
%
% Inputs:
% obj  -- initialized instance of the spher_proj class
% ndim -- number 3 or 4 -- depending on what kind of
%         transformation (3D -- momentum only or
%         4D -- momentum and energy) are requested
% Output:
% rot_to_img
%      -- 3x3 or 4x4 rotation matrix, which orients spherical
%         coordinate system and transforms momentum and energy
%         in Crystal Cartesian coordinates into oriented
%         spherical coordinate system where angular coordinates
%         are calculated
% offset
%     -- the centre of spherical coordinate system in Crystal
%        Cartesian coordinates.
% theta_to_ang
%     -- depending on the projection type, the constant used to
%        convert Theta angles in radians to Theta angles in
%        degrees or vice versa.
% phi_to_ang
%     -- depending on the projection type, the constant used to
%        convert Phi angles in radians to Phi angles in
%        degrees or vice versa.

%
% TODO: #954 NEEDS verification:
rot_to_img = obj.pix_to_matlab_transf_;
if ndim == 3
    offset   = (bmatrix(obj.alatt,obj.angdeg)*obj.offset(1:3)')';
elseif ndim == 4
    rot_to_img = [rot_to_img,[0;0;0];[0,0,0,1]];
    offset3   = (bmatrix(obj.alatt,obj.angdeg)*obj.offset(1:3)')';
    offset   = [offset3,obj.offset(4)];
else
    error('HORACE:spher_proj:invalid_argument', ...
        'ndims can only be 3 and 4. Provided: %s', ...
        disp2str(ndim));
end
if obj.type_(2) == 'r'
    theta_to_ang = 1;
else
    theta_to_ang = 180/pi;
end
if obj.type_(3) == 'r'
    phi_to_ang = 1;
else
    phi_to_ang = 180/pi;
end
