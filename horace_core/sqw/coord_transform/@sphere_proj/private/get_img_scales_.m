function [img_scales,obj] = get_img_scales_(obj)
%GET_IMG_SCALES:  Calculate image scales using projection type
%
% Input:
% obj -- initialized sphere_proj object with defined lattice
%        and "type" - property containing acceptable 3-letter
%        type code.
% Returns:
% img_scales  -- 1x3 elements array, containing scaling factors
%                for every scaled direction, namely:
% for |Q|:
% 'a' -- Angstrom,
% 'r' -- max(\vec{u}*\vec{h,k,l}) = 1
% 'p' -- |u| = 1
% 'h','k' or 'l' -- \vec{Q}/(a*,b* or c*) = 1;
% for angular units theta, phi:
% 'd' - degree, 'r' -- radians
% For energy transfer:
% 'e'-energy transfer in meV (no other scaling so may be missing)

if isempty(obj.img_scales_cache_)
    img_scales = ones(1,3);
    if obj.type(1) == 'a'
        img_scales(1) = 1;
    elseif obj.type(1) == 'p'
        bm = obj.bmatrix(3);
        proj = bm*eye(3);
        norm_angstom = arrayfun(@(nd)norm(proj(:,nd)),1:3);
        img_scales(1) = max(norm_angstom);
    elseif obj.type(1) == 'r'
        bm = obj.bmatrix(3);
        u_angstrom = bm*obj.u(:);
        img_scales(1) = norm(u_angstrom);
    elseif obj.type(1) == 'h'
        [~,arlu] = obj.bmatrix(3);
        img_scales(1) = arlu(1);
    elseif obj.type(1) == 'k'
        [~,arlu] = obj.bmatrix(3);
        img_scales(1) = arlu(2);
    elseif obj.type(1) == 'l'
        [~,arlu] = obj.bmatrix(3);
        img_scales(1) = arlu(3);
    end
    if obj.type_(2) == 'r'
        img_scales(2) = 1;
    else                  % theta_to_ang
        img_scales(2) = 180/pi;
    end
    if obj.type_(3) == 'r'
        img_scales(3) = 1;
    else                  % phi_to_ang
        img_scales(3) = 180/pi;
    end
    obj.img_scales_cache_ = img_scales;
else
    img_scales = obj.img_scales_cache_;
end