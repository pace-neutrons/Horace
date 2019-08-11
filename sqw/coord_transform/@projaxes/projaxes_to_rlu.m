function [rlu_to_ustep, u_to_rlu, ulen, mess] = projaxes_to_rlu (proj, alatt, angdeg, ustep)
% Determine matricies to convert rlu <=> projection axes, and their lengths
%
%   >> [rlu_to_ustep, u_to_rlu, ulen] = projaxes_to_rlu (proj, alatt, angdeg)
%   >> [rlu_to_ustep, u_to_rlu, ulen] = projaxes_to_rlu (proj, alatt, angdeg, ustep)
%
% The projection axes are three vectors that may or may not be orthononal
% which are used to create the bins in an sqw object. The bin sizes are in ustep
%
% Input:
% ------
%   proj    projaxes object containg information about projection axes
%          (type >> help projaxes for details)
%   alatt   Row vector of lattice parameters (Angstroms)
%   angdeg  Row vector of lattice angles (degrees)
%   ustep   Row vector giving step sizes along the projection axes as multiple
%           of the projection axes (e.g. [0.05,0.05,0.025]
%           Default if not given: [1,1,1] i.e. unit step
%
% Output:
% -------
%   rlu_to_ustep    Matrix to convert components of a vector expressed
%                  in r.l.u. to the components along the projection axes
%                  u1,u2,u3, as multiples of the step size along those axes
%                       Vstep(i) = rlu_to_ustep(i,j)*Vrlu(j)
%
%   u_to_rlu        The projection axis vectors u1, u2, u3 in reciprocal
%                  lattice vectors. The ith column is ui in r.l.u. i.e.
%                       ui = u_to_rlu(:,i)
%
%   ulen            Row vector of lengths of ui in Ang^-1
%
%   mess            Error message
%                   - all OK:   empty
%                   - if error: message, and rlu_to_ustep, u_to_rlu, ulen are empty
%


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring


if ~exist('ustep','var')
    ustep=[1,1,1];
end

[b, arlu, angrlu, mess] = bmatrix(alatt, angdeg);
if ~isempty(mess); rlu_to_ustep=[]; u_to_rlu=[]; ulen=[]; return; end

u=proj.u;
v=proj.v;
[ubmat, mess] = ubmatrix(u,v,b);  % get UB matrix
if ~isempty(mess); rlu_to_ustep=[]; u_to_rlu=[]; ulen=[]; return; end
ubinv = inv(ubmat);         % inverse of ub matrix

if isempty(proj.w)
    w=ubinv(:,3)';  % perpendicular to u and v, length 1 Ang^-1, forms rh set with u and v
else
    w=proj.w;
    if ubmat(3,:)*w'<0
        w=-w;       % ensure u,v,w make a rh set
    end
end

uvw=[u(:),v(:),w(:)];
uvw_orthonorm=ubmat*uvw;    % u,v,w in the orthonormal frame defined by u and v


u_to_rlu = zeros(3,3);
ulen = zeros(1,3);
ustep_to_rlu = zeros(3,3);

type=proj.type;
if ~proj.nonorthogonal
    % Get orthogonal Q vectors in r.l.u., u1||u, u2 perp. u1 in plane of u and v, u3 forms rh set with u1,u2:
    % (Note ui is parallel to ubinv(:,i) in r.l.u.; length of this vector is presently 1 Ang^-1;
    %  normalise these vectors according to argument 'type', get step, and finally get inverse)
    for i=1:3
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = 1/max(abs(ubinv(:,i)));       % length of ui in Ang^-1
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;                            % length of ui in Ang^-1
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = uvw_orthonorm(i,i);
        end
        u_to_rlu(:,i) = ubinv(:,i)*ulen(i);
        ustep_to_rlu(:,i) = ustep(i)*u_to_rlu(:,i);
    end
else
    % Keep non-orthogonality of u,v, and w (if given)
    for i=1:3
        veclen=norm(uvw_orthonorm(:,i));
        if lower(type(i))=='r'      % normalise so ui has max(abs(h,k,l))=1
            ulen(i) = veclen/max(abs(uvw(:,i)));
            u_to_rlu(:,i) = uvw(:,i)/max(abs(uvw(:,i)));
        elseif lower(type(i))=='a'  % ui normalised to 1 Ang^-1
            ulen(i) = 1;
            u_to_rlu(:,i) = uvw(:,i)/veclen;
        elseif lower(type(i))=='p'  % normalise so ui has length of projection of u,v,w along ui
            ulen(i) = veclen;
            u_to_rlu(:,i) = uvw(:,i);
        end
        ustep_to_rlu(:,i) = ustep(i)*u_to_rlu(:,i);
    end
end
rlu_to_ustep = inv(ustep_to_rlu);   % matrix to convert a vector in r.l.u. to no. steps along u1, u2, u3
