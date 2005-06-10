function ub = ubmat (u, v, b)
% Calculate UB matrix that transforms components of a vector given in r.l.u.
% into the components in an orthonormal frame defined by the two vectors
% u and v (each given in r.l.u):
%
%   e1  parallel to u
%   e2  in the plane of u and v, with a +ve component along v
%   e3  perpendicular to u and v
% 
%
% Syntax:
%   >> ub = ubmat(u, v, b)
%
%   u, v    Two vectors expressed in r.l.u.
%   b       B-matrix of Busing and Levy (as calulcated by function bmat)
%
% Use the matrix ub to convert components of a vector as follows:
%
%   Vuv(i) = UB(i,j) Vrlu(j)

% Author:
%   T.G.Perring     01/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring


if size(u,2)>1; u=u'; end    % convert to column vector
if size(v,2)>1; v=v'; end    % convert to column vector

uc = b*u;   % Get u, v in crystal cartesian coordinates
vc = b*v;   

e1 = uc/norm(uc);
e3 = cross(uc,vc)/norm(cross(uc,vc));
e2 = cross(e3,e1);

umat = [e1';e2';e3']/det([e1';e2';e3']);    % renormalise to ensure determinant = 1
ub = umat*b;
