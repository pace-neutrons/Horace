function [b, arlu, angrlu] = bmat (this)
% Calculate B matrix of Busing and Levy, returning also the reciprocal
% lattice vector in Angstrom^-1 and the reciprocal lattice angles are in
% radians
%
% Syntax:
%   >> b = bmat(crystal)
%   >> [b, arlu, angrlu] = bmat(this)
%
% uses 
% Input:
% ------
%   alatt   vector containing lattice parameters (Ang) [row or column vector]
%   angdeg  vector containing lattice angles (degrees) [row or column vector]
%
% Output:
% -------
%   b       B matrix of Busing & Levy [3x3 matrix]
%   arlu    Reciprocal lattice vectors (Ang^-1) [row vector]
%   angrlu  Reciprocal lattice angles (deg) [row vector]
%   mess    Error message
%               - all OK:   empty
%               - if error: message, and b, arlu, angrlu are empty
%
%
% Matrix B is used to tranform components of a vector in r.l.u. to those
% in crystal cartesian coordinates , that is, an orthonormal frame in which
% x || a*, z || cross(a*,b*), y perp. x,y
%
%   Vcryst(i) = B(i,j) Vrlu(j)
%

% Original author: T.G.Perring
%
% $Revision: 301 $ ($Date: 2009-11-03 20:52:59 +0000 (Tue, 03 Nov 2009) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring

%-----------------------

alatt = this.lattice_param;
ang = this.lattice_angles*(pi/180);
try
%  auxiliary matrix describing the volume of a bravice cell and some its
%  symmetries
a = [      1     , cos(ang(3)), cos(ang(2));...
     cos(ang(3)),      1      , cos(ang(1));...
     cos(ang(2)), cos(ang(1)),      1       ];

q = sqrt(abs(det(a)));
% reciprocal lattice -- formula derived from a and q above after long
% calculations
as = (2*pi/q)*(abs(sin(ang(1)))/alatt(1));
bs = (2*pi/q)*(abs(sin(ang(2)))/alatt(2));
cs = (2*pi/q)*(abs(sin(ang(3)))/alatt(3));
% angles between the reciprocal axis 
aa = acos( (cos(ang(2))*cos(ang(3))-cos(ang(1)))/abs(sin(ang(2))*sin(ang(3))) );
bb = acos( (cos(ang(3))*cos(ang(1))-cos(ang(2)))/abs(sin(ang(3))*sin(ang(1))) );
cc = acos( (cos(ang(1))*cos(ang(2))-cos(ang(3)))/abs(sin(ang(1))*sin(ang(2))) );
% b-matix as in Acta Cryst. (1967). 22, 457
b = [as,      bs*cos(cc),                   cs*cos(bb);...
      0, bs*abs(sin(cc)), -cs*abs(sin(bb))*cos(ang(1));...
      0,               0,                 2*pi/alatt(3)];
if nargout >= 2
    arlu = [as, bs, cs];
end

if nargout >= 3
    angrlu = [aa, bb, cc]*(180/pi);
end



%-----------------------
catch err
    b = [];
    arlu = [];
    angrlu = [];
    error('Crystal-Bmatrix: Unable to calculate b-matrix - check lattice parameters: error %s',err.message);
end
