function [img_to_u, u_to_img, ulen] = projaxes_to_rlu_(obj)
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
%                 in r.l.u. to the components along the projection axes
%                 u1,u2,u3, as multiples of the step size along those axes
%                       Vstep(i) = rlu_to_ustep(i,j)*Vrlu(j)
%
%   u_to_img      The projection axis vectors u_1, u_2, u_3 in reciprocal
%                 lattice vectors. The ith column is u_i in r.l.u. i.e.
%                 ui = u_to_rlu(:,i)
%
%   ulen          Row vector of scales of ui in Ang^-1
%
%
% Original author: T.G.Perring
%
%


[b_mat,rlu_vec_len] = bmatrix(obj.alatt, obj.angdeg);

u=obj.u;
v=obj.v;
b_vec_directions = b_mat./rlu_vec_len;
ubmat_norm = ubmatrix(u,v,b_vec_directions);  % get UB matrix normalized by rlu vector length
type=obj.type;
if isempty(obj.w) %
    uv_ortho = ubmat_norm*[u(:),v(:)];
    w = cross(uv_ortho(:,1),uv_ortho(:,2));
    w = w/norm(w);
    if ~obj.type_is_defined_explicityly_
        type(3) = 'r';
    end
else
    w=obj.w;
    if ubmat_norm(3,:)*w'<0
        w=-w;       % ensure u,v,w make a rh set
    end
    if ~obj.type_is_defined_explicitly_
        type(3) = 'p';
    end
end

uvw=[u(:),v(:),w(:)];
uvw_orthonorm=ubmat_norm*uvw;    % u,v,w in the orthonormal (Crystal Cartesian)
% frame defined by u and v

img_to_u = zeros(3,3);
ulen = zeros(1,3);


if obj.nonorthogonal
    % Keep non-orthogonality of u,v, and w (if given)
    for i=1:3
        veclen=norm(uvw_orthonorm(:,i));
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = max(abs(uvw(:,i)))*rlu_vec_len(i);
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = veclen;
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = veclen*rlu_vec_len(i);
        end
        img_to_u(:,i) = uvw_orthonorm(:,i)/ulen(i);
    end
else
    % Get orthogonal Q vectors in r.l.u., u1||u, u2 perp. u1 in plane of u and v, u3 forms rh set with u1,u2:
    % (Note ui is parallel to ubinv(:,i) in r.l.u.; length of this vector is presently 1 Ang^-1;
    %  normalise these vectors according to argument 'type', get step, and finally get inverse)

    for i=1:3
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = max(abs(ubmat_norm(:,i)))*rlu_vec_len(i);       % length of ui in Ang^-1
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;            % length of ui in Ang^-1
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = norm(uvw_orthonorm(:,i))*rlu_vec_len(i);
        end
        img_to_u(:,i) = ubmat_norm(:,i)/ulen(i);
    end
end
u_to_img = inv(img_to_u);   % matrix to convert a vector in r.l.u. to no. steps along u1, u2, u3
