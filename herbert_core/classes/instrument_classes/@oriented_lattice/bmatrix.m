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

ang = angdeg*(pi/180);
cosa = cos(ang);
sina = abs(sin(ang));

a = [    1 , cosa(3),    cosa(2);...
    cosa(3),      1 ,    cosa(1);...
    cosa(2), cosa(1),      1    ];

q = sqrt(abs(det(a)));

as = (2*pi/q)*(sina(1)/alatt(1));
bs = (2*pi/q)*(sina(2)/alatt(2));
cs = (2*pi/q)*(sina(3)/alatt(3));

% reciprocal lattice angles
aa = acos( (cosa(2)*cosa(3)-cosa(1))/(sina(2)*sina(3)) );

cos_bb = (cosa(3)*cosa(1)-cosa(2))/(sina(3)*sina(1));
cos_cc = (cosa(1)*cosa(2)-cosa(3))/(sina(1)*sina(2));
bb = acos( cos_bb );
cc = acos( cos_cc );
% b-matrix as in Acta Cryst. (1967). 22, 457
b = [as,   bs*cos_cc      ,   cs*cos_bb             ;...
    0  ,   bs*abs(sin(cc)),  -cs*abs(sin(bb))*cosa(1);...
    0  ,   0              ,   2*pi/alatt(3)         ];
%-----------------------
if nargout >= 2
    arlu = [as, bs, cs];
    if nargout >= 3
        angrlu = [aa, bb, cc]*(180/pi);
    end
end

