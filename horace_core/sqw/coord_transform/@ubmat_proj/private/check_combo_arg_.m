function obj = check_combo_arg_(obj)
% Validate line_proj parameters that depend on each other.
%
%
%
% Check u and v
% do not bother calculating real transformation if lattice is undefined
% more important for debugging than anything else, as you do not debug
% empty constructor
calc_transformation = true;
if ~obj.alatt_defined
    obj.alatt_ = 2*[pi,pi,pi];
    calc_transformation  = false;
end
if ~obj.angdeg_defined
    obj.angdeg_ = 90*ones(1,3);
    calc_transformation  = false;
end

if calc_transformation
    obj.q_to_img_cache_ = [];
    obj.q_offset_cache_ = [];
    obj.ulen_cache_     = [];
    [q_to_img_cache,q_offset_cache,img_scales,obj] = ...
        obj.get_pix_img_transformation(4);
    obj.q_to_img_cache_ = q_to_img_cache;
    obj.q_offset_cache_ = q_offset_cache;
    obj.ulen_cache_     = img_scales;
else
    obj.q_to_img_cache_ = eye(4);
    obj.q_offset_cache_ = zeros(4,1);
    obj.ulen_cache_     = ones(1,4);
end
