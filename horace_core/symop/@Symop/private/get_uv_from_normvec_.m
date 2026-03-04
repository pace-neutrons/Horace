function [u,v,normvec] = get_uv_from_normvec_(normvec,normvec_in_rlu,bmat)
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

% take 3 basic right handed coordinate system in rlu
uv_trial = {{[1;0;0],[0;1;0]},{[0;1;0],[0;0;1]},{[0;0;1],[1;0;0]}};

if normvec_in_rlu
    normvec = bmat*normvec(:);
end
normvec = normvec/norm(normvec);
 
max_length = 0;
for i = 1:3
    uv = uv_trial{i};
    ubm = ubmatrix(uv{:},bmat);
    sys_normal = cross(ubm*uv{1},ubm*uv{2});
    length = abs((ubm*normvec(:))'*(sys_normal(:)/norm(sys_normal)));
    if length>max_length
        max_length = length;
        uv_selected = uv;
    end
end
u = bmat*uv_selected{1};

u = u - (normvec'*(normvec(:)'*u))'; % extract projection to the normvec

[~,v] = Symop.check_and_brush_3vector(bmat\cross(normvec,u)); % get normal vector and convert to rlu
[~,u] = Symop.check_and_brush_3vector(bmat\u);% convert to rlu
if normvec_in_rlu
    [~,normvec] = Symop.check_and_brush_3vector(bmat\normvec);
end
end
