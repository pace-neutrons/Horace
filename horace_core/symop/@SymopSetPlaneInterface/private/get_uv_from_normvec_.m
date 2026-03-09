function [u,v,normvec,normvec_in_rlu] = get_uv_from_normvec_(normvec,normvec_in_rlu,bmat)
%SET_UV_FROM_NORMVEC Given normvec to a plane, and assuming that
% main part (the longest component) of this vector is parallel
% to z-axis of some coordinate system, identify this coordinate
% system and return u,v vectors of this system, which belong to
% a plane, orthogonal to this vector.
%
% This is unambiguous operation in orthogonal system, but for
% non-orthogonal coordinate system may return unexpected
% results, so it is better to use u,v to define plane in
% non-orthogonal system.
%
% Inputs:
% normvec         -- normal vector used to identify plane of
%                    interest
% normvec_in_rlu  -- boolean set to true if input vector is
%                    expressed in rlu
% bmat            -- b-matrix used for conversion from rlu to
%                    Crystal Cartesian coordinate system
%
% Returns:
% u               -- first vector located in plane of interest,
%                    orthogonal to normvect
% v               -- second vector located in plane of
%                    interest, orthogonal to normvect.
% normvec         -- unit vector in CC coordinate system
%                    defined by input normvect but normalized
%                    so that its CC projection has unit length.
%                    if normvec_in_rlu is true, this vector is converted to
%                    rlu

if isempty(normvec_in_rlu)
    if is_diagonal_matr(bmat)
        normvec_in_rlu = false;
    else
        error('HORACE:SymopSetPlaneInterface:invalid_argument',[ ...
            'When symmetry plane is defined from normvector in non-orthogonal system,\n' ...
            'one have to provide the description of this sytem, namely providing key ("rlu" or "cc")\n' ...
            'to constructor or setting hidden property "input_nrmv_in_rlu" to true or false\n' ...
            'This description have not been provided']);
    end
end

if normvec_in_rlu
    normvec = bmat*normvec(:);
end
normvec = normvec/norm(normvec);

u_suggestions = {[1;0;0],[0;1;0],[0;0;1]};
max_val = 0;
u_selected = [];
for i=1:3
    u = bmat\u_suggestions{i};
    u = u/norm(u);
    ortho_vec_length = norm(cross(u(:),normvec));
    if ortho_vec_length == 1
        u_selected = u(:);
        break;
    end
    if ortho_vec_length > max_val
        u_selected = u(:);
        max_val = ortho_vec_length;
    end
end
u = u_selected;

u = bmat*u(:);

u = u - (normvec'*(normvec(:)'*u))'; % extract projection to the normvec

[~,v] = Symop.check_and_brush_3vector(bmat\cross(normvec,u)); % get normal vector to uv and convert to it rlu
[~,u] = Symop.check_and_brush_3vector(bmat\u);% convert to rlu

end
