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
% 'r' -- scale = max(\vec{u}*\vec{e_h,e_k,e_l}) -- projection of u to
%                                       unit vectors in hkl directions
% 'p' -- |u| = 1 -- i.e. scale = |u| (in Crystal Cartesizan)
% 'h', 'k' or 'l' -- i.e. scale = (a*, b* or c*);
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
        u_cc = bm*obj.u(:); % u in Crystal Cartesian
        img_scales(1) = norm(u_cc);
    elseif obj.type(1) == 'r'
        [bm,arlu] = obj.bmatrix(3);
        hkl_cc    = bm*eye(3)./arlu(:); % unit vectors in hkl direction
        u_cc      = bm*obj.u(:); % u in Crystal Cartesian
        proj2hkl  = hkl_cc*u_cc; % projection u_cc to unit vectors in hkl directions
        img_scales(1) = max(proj2hkl);
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