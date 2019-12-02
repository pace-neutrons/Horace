function [b, arlu, angrlu] = bmatrix(obj)
% Calculate B matrix of Busing and Levy, returning also the reciprocal
% lattice vector in Angstrom^-1 and the reciprocal lattice angles in degrees
%
%
%   >>b =  obj.bmatrix()
%   >>[b, arlu, angrlu] = obj.bmatrix ()
%
% Used class parameters:
% ------
%   alatt   vector containing lattice parameters (Ang) [row or column vector]
%   angdeg  vector containing lattice angles (degrees) [row or column vector]
%
% Output:
% -------
%   b       B matrix of Busing & Levy [3x3 matrix]
%   arlu    Reciprocal lattice vectors (Ang^-1) [row vector]
%   angrlu  Reciprocal lattice angles (deg) [row vector]
%
% Matrix B is used to tranform components of a vector in r.l.u. to those
% in crystal cartesian coordinates , that is, an orthonormal frame in which
% x || a*, z || cross(a*,b*), y perp. x,y
%
%   Vcryst(i) = B(i,j) Vrlu(j)


% Original author: T.G.Perring
%
% $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring
%

angdeg = obj.angdeg;
alatt  = obj.alatt;
[b, arlu, angrlu] = bmatrix(angdeg, alatt);
