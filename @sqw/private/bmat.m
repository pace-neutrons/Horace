function [b, arlu, angrlu, mess] = bmat (alatt, angdeg)
% Calculate B matrix of Busing and Levy, returning also the reciprocal
% lattice vector in Angstrom^-1 and the reciprocal lattice angles in degrees
%
% Syntax:
%   >> b = bmat(alatt, ang)
%   >> [b, arlu, angrlu] = bmat(alatt, ang)
%
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
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


if max(angdeg)>=180 | min(angdeg)<=0
    b = [];
    arlu = [];
    angrlu = [];
    mess = 'ERROR: Check lattice angles';
    return
elseif min(alatt)<= 0
    b = [];
    arlu = [];
    angrlu = [];
    mess = 'ERROR: Check lattice parameters';
    return
end


%-----------------------
try
ang = angdeg*(pi/180);
a = [      1     , cos(ang(3)), cos(ang(2));...
     cos(ang(3)),      1      , cos(ang(1));...
     cos(ang(2)), cos(ang(1)),      1       ];

q = sqrt(abs(det(a)));

as = (2*pi/q)*(abs(sin(ang(1)))/alatt(1));
bs = (2*pi/q)*(abs(sin(ang(2)))/alatt(2));
cs = (2*pi/q)*(abs(sin(ang(3)))/alatt(3));

aa = acos( (cos(ang(2))*cos(ang(3))-cos(ang(1)))/abs(sin(ang(2))*sin(ang(3))) );
bb = acos( (cos(ang(3))*cos(ang(1))-cos(ang(2)))/abs(sin(ang(3))*sin(ang(1))) );
cc = acos( (cos(ang(1))*cos(ang(2))-cos(ang(3)))/abs(sin(ang(1))*sin(ang(2))) );

b = [as,      bs*cos(cc),                   cs*cos(bb);...
      0, bs*abs(sin(cc)), -cs*abs(sin(bb))*cos(ang(1));...
      0,               0,                 2*pi/alatt(3)];
if nargout >= 2
    arlu = [as, bs, cs];
end

if nargout >= 3
    angrlu = [aa, bb, cc]*(180/pi);
end

if nargout >= 4
    mess = '';
end

%-----------------------
catch
    b = [];
    arlu = [];
    angrlu = [];
    mess = 'ERROR: Unable to calculate b-matrix - check lattice parameters';
end
