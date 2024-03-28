function [rot_to_img,offset_cc,img_scales,offset_present,obj]= ...
    get_pix_img_transformation_(obj,ndim,varargin)
% Return the constants and parameters used for transformation
% from Crystal Cartesian to spherical coordinate system and
% back
%
% Inputs:
% obj  -- initialized instance of the sphere_proj class
% ndim -- number 3 or 4 -- depending on what kind of
%         transformation (3D -- momentum only or
%         4D -- momentum and energy) are requested
% Output:
% rot_to_img
%      -- 3x3 or 4x4 rotation matrix, which orients spherical
%         coordinate system and transforms momentum and energy
%         in Crystal Cartesian coordinates into oriented
%         Crystal Cartesian coordinate system used for calculateing angular
%         coordinates
% offset_cc
%     -- the centre of spherical coordinate system in Crystal
%        Cartesian coordinates.
% img_scales
%     -- depending on the projection type, the 3-vectors
%        containing the scales used on image.
%        depending on the projection type, elements 2,3
%        (d/r) elements 2,3 of scales contain constand used to convert
%        angles from degrees to radians or vice versa
%
% TODO: #954 NEEDS verification:
rot_to_img = obj.pix_to_matlab_transf_;
offset_hkl = obj.offset(:);
offset_present = any(abs(offset_hkl)>4*eps("single"));

[alignment_needed,alignment_mat] = aProjectionBase.check_alignment_needed(varargin{:});

if ndim == 3
    rot_to_img = rot_to_img(1:3,1:3);
    if alignment_needed
        rot_to_img  = alignment_mat*rot_to_img;
    end
elseif ndim ~= 4
    error('HORACE:sphere_proj:invalid_argument', ...
        'ndims can only be 3 and 4. Provided: %s', ...
        disp2str(ndim));
end

if offset_present
    offset_cc   = (obj.bmatrix(ndim)*offset_hkl(1:ndim))';
    if alignment_needed
        % Note inversion! It is correct -- see how it used in transformation
        offset_cc = alignment_mat'*offset_cc(:);
    end
else
    offset_cc = zeros(1,ndim);
end
[img_scales,obj] = get_img_scales(obj);
