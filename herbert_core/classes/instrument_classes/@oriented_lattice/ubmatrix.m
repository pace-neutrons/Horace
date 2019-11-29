function [ub,umat] = ubmatrix (obj,varargin)
% Calculate UB matrix that transforms components of a vector given in r.l.u.
% into the components in an orthonormal frame defined by the two vectors
% u and v (each given in r.l.u)
%
%   >> ub = obj.ubmatrix()
%   >> ub = obj.ubmatrix(bmatrix)
%
%   >> [ub, umat] = obj.ubmatrix()    % full syntax
%
% Used class parameters:
% -------
%   u, v    Two vectors expressed in r.l.u.
%   b       B-matrix of Busing and Levy (as calculated by function bmat)
%
% Output:
% -------
%   ub      UB matrix; 
%   umat    U matrix -- takes V in crystal Cartesian coords to orthonormal frame defined by u, v
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
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring
%
if nargin == 1
    b = obj.bmatrix();
else
    b = varargin{1};
end

u=obj.u';    % convert to column vector
v=obj.v';    % convert to column vector
[ub, mess, umat] = ubmatrix (u, v, b)
