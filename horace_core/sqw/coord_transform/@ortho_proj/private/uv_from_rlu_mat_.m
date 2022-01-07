function [u,v]=uv_from_rlu_mat_(obj,u_to_rlu,ulen)
% Extract initial u/v vectors, defining the plane in hkl from
% lattice parameters and the matrix converting vectors in
% crystal Cartesian coordinate system into rlu.
%
% partially inverting projaxes_to_rlu function of ortho_proj class
% as only orthogonal to u part of the v-vector can be recovered
%
% Inputs:
% u_to_rlu -- matrix used for conversion from pixel coordinate
%          system to the image coordinate system (normally
%          expressed in rlu)
% ulen  -- length of the unit vectors of the reciprocal lattice
%          units, the Horace image is expressed in
% Outputs:
% u     -- [1x3] vector expressed in rlu and defining the cut
%          direction
% v     -- [1x3] vector expressed in rlu, and together with u
%          defining the cut plain
%u_to_rlu(:,i) = ubinv(:,i)*ulen(i);


ulen_inv = 1./ulen;
ubinv = u_to_rlu.*repmat(ulen_inv,3,1);
ubmat = inv(ubinv);
b_mat = bmatrix(obj.alatt,obj.angdeg);
%ub = umat*b_mat;
umat = ubmat/b_mat;
%
u_dir = (b_mat\umat(1,:)')';
% vector, parallel to u:
u = u_dir/norm(u_dir);

% the length of the V-vector, orthogonal to u (unit vector)
% in fact real v-vector is not fully recoverable. We can
% recover only the orthogonal part
v_tr =  (b_mat\umat(2,:)')';
v = v_tr/norm(v_tr);
%
w=ubinv(:,3)';  % perpendicular to u and v, length 1 Ang^-1, forms rh set with u and v

uvw=[u(:),v(:),w(:)];
uvw_orthonorm=ubmat*uvw;    % u,v,w in the orthonormal frame defined by u and v
ulen_new = diag(uvw_orthonorm);
scale = ulen./ulen_new';
u = u*scale(1);
v = v*scale(2);
