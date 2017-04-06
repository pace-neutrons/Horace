function [ub,umat] = ubmatrix (obj)
% Calculate UB matrix that transforms components of a vector given in r.l.u.
% into the components in an orthonormal frame defined by the two vectors
% u and v (each given in r.l.u)
%
%   >> ub = ubmatrix (u, v, b)
%
%   >> [ub, umat] = ubmatrix (u, v, b)    % full syntax
%
% Uses:
% -------
%   u, v    Two vectors expressed in r.l.u.
%   b       B-matrix of Busing and Levy (as calculated by function bmat)
%
% Output:
% -------
%   ub      UB matrix; empty if there is a problem
%   umat    U matrix
%
% The orthonormal frame defined by vectors u and v is:
%   e1  parallel to u
%   e2  in the plane of u and v, with a +ve component along v
%   e3  perpendicular to u and v
%
% Use the matrix ub to convert components of a vector as follows:
%
%   Vuv(i) = UB(i,j) Vrlu(j)
%
% Also:
%
%   Vuv(i) = U(i,j) Vcryst(j)   % NOTE: inv(U) == U'


% Original author: T.G.Perring
%
% $Revision: 1170 $ ($Date: 2016-02-01 17:35:02 +0000 (Mon, 01 Feb 2016) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring
%
b = obj.bmatrix();

if size(u,2)>1; u=u'; end    % convert to column vector
if size(v,2)>1; v=v'; end    % convert to column vector

uc = b*u;   % Get u, v in crystal Cartesian coordinates
vc = b*v;   

e1 = uc/norm(uc);
e3 = cross(uc,vc)/norm(cross(uc,vc));
e2 = cross(e3,e1);

umat = [e1';e2';e3']/det([e1';e2';e3']);    % renormalise to ensure determinant = 1
ub = umat*b;
