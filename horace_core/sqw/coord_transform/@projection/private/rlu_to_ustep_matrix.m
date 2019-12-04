function [rlu_to_ustep, u_to_rlu, ulen, mess] = rlu_to_ustep_matrix (alatt, angdeg, u, v, ustep, type, w)
%  Perform various calculations with reciprocal lattice for producing plot axes
%
% Syntax:
%   >> [rlu_to_ustep, u_to_rlu, ulen] = rlu_to_ustep_matrix (alatt, angdeg, u, v, ustep, type, w)
%
% input:
% -----------
%   alatt(1:3)  Row vector of lattice parameters (Angstroms)
%   angdeg(1:3) Row vector of lattice angles (degrees)
%   u(1:3)      Row vector defining first plot axis (r.l.u.)
%   v(1:3)      Row vector defining plane of plot in Q-space (r.l.u.)
%           The plot plane is defined by u and the perpendicular to u in the
%           plane of u and v. The unit lengths of the axes are determined by the
%           character codes in the variable 'type' described below
%            - if 'a': unit length is one inverse Angstrom
%            - if 'r': then if (h,k,l) in r.l.u., is normalised so max(abs(h,k,l))=1
%            - if 'p': then normalised so that if the orthogonal set created from u and v is u1, u2, u3:
%                       |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
%                      i.e. the projections of u,v,w along u1,u2,u3 match the lengths of u1,u2,u3
%
%   ustep(1:3)  Row vector giving step size along u1, u2 and u3 axes
%   type        Units of binning and thickness: a three-character string,
%              each character indicating if u1, u2, u3 normalised to Angstrom^-1
%              or r.l.u., max(abs(h,k,l))=1 - 'a' and 'r' respectively. e.g. type='arr'
%   w(1:3)      Row vector defining the line of the third axis. Only needed if type(3)='p' (r.l.u.)
%
% output:
% -----------
%   rlu_to_ustep(1:3,1:3)   Matrix to convert components of a vector expressed
%                           in r.l.u. to multiples of the step size along the
%                           orthogonal set defined by the vectors u and v
%                       i.e.
%                           Vstep(i) = rlu_to_ustep(i,j)*Vrlu(j)
%
%   u_to_rlu(1:3,1:3)       Vectors u1, u2, u3 in reciprocal lattice vectors: 
%                           the ith column is ui i.e. ui = u_to_rlu(:,i) 
%
%   ulen(1:3)               Row vector of lengths of ui in Ang^-1
%
%   mess                    Error message
%                           - all OK:   empty
%                           - if error: message, and rlu_to_ustep, u_to_rlu, ulen are empty
%                           

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring

small=1e-12;

[b, arlu, angrlu, mess] = bmatrix(alatt, angdeg);
if ~isempty(mess); rlu_to_ustep=[]; u_to_rlu=[]; ulen=[]; return; end

[ub, mess] = ubmatrix(u,v,b);  % get UB matrix
if ~isempty(mess); rlu_to_ustep=[]; u_to_rlu=[]; ulen=[]; return; end

ubinv = inv(ub);    % inverse

% Get orthogonal Q vectors in r.l.u., u1||u, u2 perp. u1 in plane of u and v, u3 forms rh set with u1,u2:
% (Note ui is parallel to ubinv(:,i) in r.l.u.; length of this vector is presently 1 Ang^-1;
%  normalise these vectors according to argument 'type', get step, and finally get inverse)

if size(u,2)>1; u=u'; end    % convert to column vector
if size(v,2)>1; v=v'; end    % convert to column vector
if type(3)=='p'
    if length(w)~=3
        rlu_to_ustep=[]; u_to_rlu=[]; ulen=[];
        mess='Must give third vector (rlu) to define 3D grid with normalisation type ''p'' in rlu_to_ustep_matrix';
        return
    end
    if size(w,2)>1; w=w'; end    % convert to column vector
else
    w=zeros(3,1);   % dummy value
end
uvw=[u,v,w];
uvw_orthonorm=ub*uvw;   % u,v,w in the orthonormal frame defined by u and v

% Check that w is not coplanar with u and v
if type(3)=='p'
    if abs(det(uvw))<small
        rlu_to_ustep=[]; u_to_rlu=[]; ulen=[];
        mess='Third vector (rlu) to define 3D grid with normalisation type ''p'' is coplanar with u and v';
        return
    end
end

    
u_to_rlu = zeros(3,3);
ulen = zeros(1,3);
ustep_to_rlu = zeros(3,3);
for i=1:3
    if lower(type(i))=='r'
        ulen(i) = 1/max(abs(ubinv(:,i)));                   % length of ui in Ang^-1
        u_to_rlu(:,i) = ubinv(:,i)*ulen(i);                 % normalise so ui has max(abs(h,k,l))=1
        ustep_to_rlu(:,i) = ustep(i)*u_to_rlu(:,i);         % get step vector in r.l.u.
    elseif lower(type(i))=='a'
        ulen(i) = 1;                                        % length of ui in Ang^-1
        u_to_rlu(:,i) = ubinv(:,i)*ulen(i);                 % ui normalised to 1 Ang^-1 already, so just copy
        ustep_to_rlu(:,i) = ustep(i)*u_to_rlu(:,i);         % get step vector in r.l.u.
    elseif lower(type(i))=='p'
        ulen(i) = abs(uvw_orthonorm(i,i));                  % length of ui in Ang^-1; take abs in case w does not form rh set with u and v
        u_to_rlu(:,i) = ubinv(:,i)*ulen(i);                 % normalise so ui has max(abs(h,k,l))=1
        ustep_to_rlu(:,i) = ustep(i)*u_to_rlu(:,i);         % get step vector in r.l.u.
    else
        mess = 'ERROR: normalisation type for each axis must be ''r'' or ''a''';
        rlu_to_ustep=[]; u_to_rlu=[]; ulen=[]; return;
    end
end
rlu_to_ustep = inv(ustep_to_rlu);   % matrix to convert a vector in r.l.u. to no. steps along u1, u2, u3
