function obj = check_and_caclulate_vectors_and_R_(obj)
%
if obj.set_from_normvec_
    obj = set_uv_from_normvec_(obj);
else
    if norm(cross(obj.u_, obj.v_)) < 1e-6
        error('HORACE:SymopReflection:invalid_argument', ...
            'Vectors u=%s and v=%s are collinear', ...
            disp2str(obj.u_'),disp2str(obj.v_'));
    end

    Bmat = obj.b_matrix_;
    if isempty(Bmat) || ~obj.is_rlu
        e1 = obj.u_;
        e2 = obj.v_;
    else
        e1 = Bmat * obj.u_;
        e2 = Bmat * obj.v_;
    end
    n = cross(e1,e2);
    obj.normvec_ = n / norm(n);
end
obj.R_ = obj.calculate_transform();

end

function obj = set_uv_from_normvec_(obj)
%SET_UV_FROM_NORMVEC Given normvec to a plane, and assuming that
%main part (the longest component) of this vector is parallel to z-axis of
%some coordinate system, identify this coordinate system and set up u,v
%vectors of this system
% This is unambiguous operation in orthogonal system, but for
% non-orthogonal coordinate system

end