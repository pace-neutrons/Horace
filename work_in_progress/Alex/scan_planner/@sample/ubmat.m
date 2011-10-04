function [ub,b] = ubmat (this,u, v)
% Calculate UB matrix that transforms components of a vector given in r.l.u.
% into the components in an orthonormal frame defined by the two vectors
% u and v (each given in r.l.u)
%
% Syntax:
%   >> [ub,b] = ubmat(this,u, v)
%
% Input:
% -------
%   u, v    Two vectors expressed in r.l.u.
%   b       B-matrix of Busing and Levy (as calulcated by function bmat)
%
% Output:
% -------
%   ub      UB matrix; empty if there is a problem
%   mess    Error message; empty if all OK
%
% The orthonormal frame defined by vectors u and v is:
%   e1  parallel to u
%   e2  in the plane of u and v, with a +ve component along v
%   e3  perpendicular to u and v
%
% Use the matrix ub to convert components of a vector as follows:
%
%   Vuv(i) = UB(i,j) Vrlu(j)

% Original author: T.G.Perring
%
% $Revision: 301 $ ($Date: 2009-11-03 20:52:59 +0000 (Tue, 03 Nov 2009) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring


b   = bmat(this);

if size(u,2)>1; u=u'; end    % convert to column vector
if size(v,2)>1;  v=v'; end    % convert to column vector
    
uc = b*u;   % Get u, v in crystal cartesian coordinates
vc =  b*v;   

e1 = uc/norm(uc);
determ = norm(cross(uc,vc));
if determ<1.e-6
        error('SAMPLE:ubmat','Problem calculating ub matrix. Check u and v are not parallel');
end

e3 = cross(uc,vc)/determ;
e2 = cross(e3,e1);

umat = [e1';e2';e3']/det([e1';e2';e3']);    % renormalise to ensure determinant = 1
ub = umat*b;


