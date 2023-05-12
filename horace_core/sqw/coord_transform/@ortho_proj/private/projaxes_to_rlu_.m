function [u_to_img,ulen,b_mat,obj] = projaxes_to_rlu_(obj)
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
[ubmat,umat] = ubmatrix(u,v,b_mat);  % get UB matrix normalized by rlu vector length


type=obj.type;
if isempty(obj.w) %
    ubmat_norm = ubnat./b_vec_directions(:)';
    % the purpose of selecting default w with 'r' scale would be
    % providing the same thickness expressed in hkl cut regardless of the
    % cut direction. This may not have physical meaning for triclinic
    % lattice, but in this case you should provide w manually
    uv_ortho = ubmat_norm*[u(:),v(:)];
    w = cross(uv_ortho(:,1),uv_ortho(:,2));
    w = w/norm(w);
else
    w=obj.w;
    if ubmat(3,:)*w'<0
        w=-w;       % ensure u,v,w make a rh set
        obj.w_ = w;
    end
end

uvw=[u(:),v(:),w(:)];
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
        uvw_orth(:,i) = uvw_orth(:,i)/veclen(i);
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = r_norm;
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = veclen(i);
        end
    end
    u_to_img = inv(uvw_orth)./(ulen(:)');
else
    uvw_orth=ubmat*uvw;  % u,v,w in the orthonormal
    %                   coordinate system frame defined by u (along u) and v and
    %                   aligned with rotated Crystal Cartesian system
    %                   (A^-1)

    i = 1:3;
    vec_len = arrayfun(@(i)norm(ubmat(:,i)),i);
    r_norm = min(vec_len);
    for i=1:3
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = r_norm;
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;            % length of ui in Ang^-1
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = abs(uvw_orth(i,i));
        end
    end
    u_to_img = inv(umat)./(ulen(:)');
end


