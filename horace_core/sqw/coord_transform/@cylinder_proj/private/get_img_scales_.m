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
% 'r' -- max(\vec{u}*\vec{e_h,e_k,e_l}) = 1 -- projection of u or v to
%                                       unit vectors in hkl directions
% 'p' -- scale == length of vector u or v
%  (depending on settings type(1)== 'p' or type(2)=='p')
% 'h','k' or 'l' -- scale in selected direction (1 or 2) == (a*,b* or c*);
% for angular units theta, phi:
% 'd' - degree, 'r' -- radians
% For energy transfer:
% 'e'-energy transfer in meV (no other scaling so may be missing)

if isempty(obj.img_scales_cache_)
    img_scales = ones(1,3);
    img_scales(1) = calc_scales_(obj,obj.v(:),obj.type(1));
    img_scales(2) = calc_scales_(obj,obj.u(:),obj.type(2));
    if obj.type_(3) == 'r'
        img_scales(3) = 1;
    else                  % phi_to_ang
        img_scales(3) = 180/pi;
    end
    obj.img_scales_cache_ = img_scales;
else
    img_scales = obj.img_scales_cache_;
end

function scale = calc_scales_(obj,vec,type)

if type == 'a'
    scale  = 1;
elseif type == 'p'
    bm = obj.bmatrix(3);
    v_cc = bm*vec; % vec in Crystal Cartesian
    scale = norm(v_cc);
elseif type == 'r'
    [bm,arlu] = obj.bmatrix(3);
    hkl_cc    = bm*eye(3)./arlu(:); % unit vectors in hkl direction
    v_cc      = bm*vec; % vec in Crystal Cartesian
    proj2hkl  = hkl_cc*v_cc; % projection u_cc to unit vectors in hkl directions
    scale = max(proj2hkl);
elseif type == 'h'
    [~,arlu] = obj.bmatrix(3);
    scale = arlu(1);
elseif type == 'k'
    [~,arlu] = obj.bmatrix(3);
    scale = arlu(2);
elseif type == 'l'
    [~,arlu] = obj.bmatrix(3);
    scale = arlu(3);
end
