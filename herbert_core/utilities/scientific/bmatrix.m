function [b, arlu, angrlu] = bmatrix(alatt, angdeg)
% Calculate B matrix of Busing and Levy, returning also the reciprocal
% lattice vector in Angstrom^-1 and the reciprocal lattice angles in degrees
%
%   >> b =  bmatrix (alatt, ang)
%   >> [b, arlu, angrlu] =  bmatrix (alatt, ang)
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


% Original author: T.G.Perring
%
%
% Horace v0.1   J. van Duijn, T.G.Perring


if max(angdeg)>=180 || min(angdeg)<=0
    error('HORACE:bmatrix:invalid_argument', ...
          'some lattice angles bigger than 180 deg or less than 0 deg');
end

if min(alatt)<= 0
    error('HORACE:bmatrix:invalid_argument', ...
          'Some lattice parameters are less than 0');
end


ang  = deg2rad(angdeg);
cosa = cos(ang);
sina = abs(sin(ang));

a = [1 ,      cosa(3),    cosa(2);...
     cosa(3),      1 ,    cosa(1);...
     cosa(2), cosa(1),      1    ];

q = sqrt(abs(det(a)));

arlu = (2*pi/q)*(sina ./ alatt);

% reciprocal lattice angles
aa = acos( (cosa(2)*cosa(3)-cosa(1))/(sina(2)*sina(3)) );
bb = acos( (cosa(3)*cosa(1)-cosa(2))/(sina(3)*sina(1)) );
cc = acos( (cosa(1)*cosa(2)-cosa(3))/(sina(1)*sina(2)) );
% b-matix as in Acta Cryst. (1967). 22, 457
b = [arlu(1), arlu(2)*cos(cc)     ,  arlu(3)*cos(bb)             ;...
     0      , arlu(2)*abs(sin(cc)), -arlu(3)*abs(sin(bb))*cosa(1);...
     0      , 0                   , 2*pi/alatt(3)                ];

angrlu = rad2deg([aa, bb, cc]);

end
