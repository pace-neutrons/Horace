function [rlu_to_ustep, u_to_rlu, ulen] = rlu_to_ustep_matrix (alatt, angdeg, u, v, ustep, type)
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
%           Call the orthogonal set created from u and v: u1, u2, u3.
%   ustep(1:3)  Row vector giving step size along u1, u2 and u3 axes
%   type        Units of binning and thickness: a three-character string,
%               each character indicating if u1, u2, u3 normalised to Angstrom^-1
%               or r.l.u., max(abs(h,k,l))=1.
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

% Author:
%   T.G.Perring     01/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

[b, arlu, angrlu] = bmat (alatt, angdeg);
ub = ubmat(u,v,b);  % get UB matrix
ubinv = inv(ub);    % inverse

% Get orthogonal Q vectors in r.l.u., u1||u, u2 perp. u1 in plane of u and v, u3 forms rh set with u1,u2:
% (Note ui is parallel to ubinv(:,i) in r.l.u.; length of this vector is presently 1 Ang^-1;
%  normalise these vectors according to argument 'type', get step, and finally get inverse)

u_to_rlu = zeros(3,3);
ulen = zeros(1,3);
ustep_to_rlu = zeros(3,3);
for i=1:3
    if lower(type(i))=='r'
        u_to_rlu(:,i) = ubinv(:,i)/max(abs(ubinv(:,i)));    % normalise so ui has max(abs(h,k,l))=1
        ulen(i) = 1/max(ubinv(:,i));                        % length of u1 in Ang^-1
        ustep_to_rlu(:,i) = ustep(i)*u_to_rlu(:,i);         % get step vector in r.l.u.
    elseif lower(type(i))=='a'
        u_to_rlu(:,i) = ubinv(:,i);                         % ui normalised to 1 Ang^-1 already, so just copy
        ulen(i) = 1;                                        % length of u1 in Ang^-1
        ustep_to_rlu(:,i) = ustep(i)*ubinv(:,i);            % get step vector in r.l.u.
    else
        error('ERROR: normalisation type for each axis must be ''r'' or ''a''')
    end
end
rlu_to_ustep = inv(ustep_to_rlu);   % matrix to convert a vector in r.l.u. to no. steps along u1, u2, u3

