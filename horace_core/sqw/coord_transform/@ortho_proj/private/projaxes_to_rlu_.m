function [img_to_u, u_to_img, ulen] = projaxes_to_rlu_(proj)
% Determine matrices to convert rlu <=> projection axes, and the scaler
%
%
%   >> [rlu_to_u, u_to_rlu, ulen] = projaxes_to_rlu (proj)
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
%   rlu_to_ustep   Matrix to convert components of a vector expressed
%                  in r.l.u. to the components along the projection axes
%                  u1,u2,u3, as multiples of the step size along those axes
%                       Vstep(i) = rlu_to_ustep(i,j)*Vrlu(j)
%
%   u_to_rlu       The projection axis vectors u_1, u_2, u_3 in reciprocal
%                  lattice vectors. The ith column is u_i in r.l.u. i.e.
%                  ui = u_to_rlu(:,i)
%
%   ulen           Row vector of lengths of ui in Ang^-1
%
%
% Original author: T.G.Perring
%
%
% Horace v0.1   J. van Duijn, T.G.Perring


b_mat = bmatrix(proj.alatt, proj.angdeg);

u=proj.u;
v=proj.v;
ubmat = ubmatrix(u,v,b_mat);  % get UB matrix
umat  = ubmat/b_mat;
ubinv = inv(ubmat);         % inverse of ub matrix
type=proj.type;
if isempty(proj.w) % DO NOT UNDERSTAND THIS.
    w=ubinv(:,3)';  % perpendicular to u and v, length 1 [Ang^-1 ? Ang should be?], forms rh set with u and v
else
    w=proj.w;
    if ubmat(3,:)*w'<0
        w=-w;       % ensure u,v,w make a rh set
    end
    if type(3)=='r'
        type(3) = 'p';
        proj.type_ = type;
    end
end

uvw=[u(:),v(:),w(:)];
uvw_orthonorm=ubmat*uvw;    % u,v,w in the orthonormal (Crystal Cartesian)
% frame defined by u and v

u_to_img = zeros(3,3);
ulen = zeros(1,3);


if proj.nonorthogonal
    % Keep non-orthogonality of u,v, and w (if given)
    alatt = proj.alatt;
    for i=1:3
        veclen=norm(uvw_orthonorm(:,i));
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = veclen/max(abs(uvw(:,i)));
            u_to_img(:,i) = uvw(:,i)/max(abs(uvw(:,i)));
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;
            u_to_img(:,i) = ubinv(:,i)/bvec(i);
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = veclen;
            u_to_img(:,i) = uvw(:,i);
        end
    end
else
    % Get orthogonal Q vectors in r.l.u., u1||u, u2 perp. u1 in plane of u and v, u3 forms rh set with u1,u2:
    % (Note ui is parallel to ubinv(:,i) in r.l.u.; length of this vector is presently 1 Ang^-1;
    %  normalise these vectors according to argument 'type', get step, and finally get inverse)
    u_to_img = inv(uvw_orthonorm);
    for i=1:3
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = 1/max(abs(ubinv(:,i)));       % length of ui in Ang^-1
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;            % length of ui in Ang^-1
            u_to_img(:,i) = umat(:,i);
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = norm(uvw_orthonorm(:,i));
            u_to_img(:,i) = ubinv(:,i);            
        end

    end
end
img_to_u = inv(u_to_img);   % matrix to convert a vector in r.l.u. to no. steps along u1, u2, u3
