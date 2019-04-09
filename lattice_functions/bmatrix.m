function [b, arlu, angrlu, mess] = bmatrix(alatt, angdeg)
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
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
%
% Horace v0.1   J. van Duijn, T.G.Perring
if nargout<4
    throw_error = true;
else
    throw_error = false;
end


if max(angdeg)>=180 || min(angdeg)<=0
    mess = 'some lattice angles bigger than 180deg or less than 0 deg';
    if throw_error
        error('BMATRIX:invalid_argument',mess);
    else
        b = [];
        arlu = [];
        angrlu = [];
        return
    end
elseif min(alatt)<= 0
    mess = 'Some lattice parameters are less than 0';
    if throw_error
        error('BMATRIX:invalid_argument',mess);
    else
        b = [];
        arlu = [];
        angrlu = [];
        
        return
    end
    
    
end


try
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
    bb = acos( (cosa(3)*cosa(1)-cosa(2))/(sina(3)*sina(1)) );
    cc = acos( (cosa(1)*cosa(2)-cosa(3))/(sina(1)*sina(2)) );
    % b-matix as in Acta Cryst. (1967). 22, 457
    b = [as,   bs*cos(cc)     ,   cs*cos(bb)             ;...
        0  ,   bs*abs(sin(cc)),  -cs*abs(sin(bb))*cosa(1);...
        0  ,   0              ,   2*pi/alatt(3)         ];
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
    mess = 'Unable to calculate B matrix - check lattice parameters';
    if throw_error
        error('BMATRIX:invalid_argument',mess);
    end
end

