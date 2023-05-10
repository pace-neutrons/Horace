function [img_to_u, u_to_img, ulen,b_mat] = projaxes_to_rlu_(obj)
% Determine matrices to convert rlu <=> projection axes, and the scaler
%
%
%   >> [img_to_u, u_to_img, ulen] = projaxes_to_rlu_(proj)
%
% The projection axes are three vectors that may or may not be orthogonal
% which are used to create the bins in an sqw object. The bin sizes are in ustep
%
% Input:
% ------
%   proj    ortho_proj object containing information about projection axes
%          (type >> help ortho_proj for details)
%
% Output:
% -------
%   img_to_u      Matrix to convert components of a vector expressed
%                 in image coordinate system to the components along the projection axes
%                 u1,u2,u3, as multiples of the step size along those axes
%                       Vstep(i) = rlu_to_ustep(i,j)*Vrlu(j)
%
%   u_to_img      The projection axis vectors u_1, u_2, u_3 in reciprocal
%                 lattice vectors. The ith column is u_i in r.l.u. i.e.
%                 ui = u_to_rlu(:,i)
%
%   ulen          Row vector of scales of ui in Ang^-1
%   b_mat         Matrix transforimng hkl coordinate system into Crystal
%                 Cartesian coordinate system
%
%
% Original author: T.G.Perring; J. van Duijn; Horace v0.1
%
% Substantially changed in 2023 for Horace 4.0;


[b_mat,rlu_vec_len] = bmatrix(obj.alatt, obj.angdeg);

u=obj.u;
v=obj.v;
b_vec_directions = b_mat./rlu_vec_len;
ubmat_norm = ubmatrix(u,v,b_vec_directions);  % get UB matrix normalized by rlu vector length
umat = ubmat_norm/b_vec_directions;
type=obj.type;
if isempty(obj.w) %
    % the purpose of selecting default w with 'r' scale would be
    % providing the same thickness expressed in hkl cut regardless of the
    % cut direction. This may not have physical meaning for triclinic
    % lattice, but in this case you should provide w manually
    uv_ortho = ubmat_norm*[u(:),v(:)];
    w = cross(uv_ortho(:,1),uv_ortho(:,2));
    w = w/norm(w);
else
    w=obj.w;
    if ubmat_norm(3,:)*w'<0
        w=-w;       % ensure u,v,w make a rh set
    end
end

uvw=[u(:),v(:),w(:)];


img_to_u = zeros(3,3);
ulen = zeros(1,3);


if obj.nonorthogonal
    uvw_orth=b_mat*uvw;  % u,v,w in the orthonormal coordinate system
    %                    frame attached to reciprocal lattice
    %                    vectors, i.e. Crystal Cartezian coordinate system

    i = 1:3;
    veclen = arrayfun(@(i)norm(uvw_orth(:,i)),i);
    r_norm = max(veclen);
    % Keep non-orthogonality of u,v, and w (if given)
    for i=1:3
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = r_norm;
            uvw_orth(:,i) = uvw_orth(:,i)*(r_norm/veclen(i));
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;
            uvw_orth(:,i) = uvw_orth(:,i)/veclen(i); % get unit vector in this direction
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = veclen(i);
        end
        img_to_u(:,i) = uvw_orth(:,i);
    end
else
    uvw_orth=ubmat_norm.*rlu_vec_len(:)*uvw;  % u,v,w in the orthonormal
    %                    coordinate system frame defined by u (along u) and v and
    %                    aligned with rotated Crystal Cartesian system
    %                    (A^-1)

    i = 1:3;
    coord_norm = arrayfun(@(i)norm(rlu_vec_len(i)*ubmat_norm(:,i)),i);
    r_norm = min(coord_norm);
    for i=1:3
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = r_norm;
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;            % length of ui in Ang^-1
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = norm(uvw_orth(:,i));
        end
        img_to_u(:,i) = umat(:,i)*ulen(i);
    end
end
u_to_img = inv(img_to_u);   % matrix to convert a vector in r.l.u. to no. steps along u1, u2, u3
