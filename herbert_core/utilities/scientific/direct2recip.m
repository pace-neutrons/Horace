function b = direct2recip(alatt, angdeg)
% Calculates reciprocal vectors b_i of reciprocal lattice from the direct
% lattice parameters a,b,c (in Angstroms) and the reciprocal lattice angles
% \alpha, \beta and \gamma (in degrees) in orthogonal coordinate system
% with x-axis directed along a
%
%   >> b =  direct2recip(alatt, ang)
%
% Input:
% ------
%   alatt   vector containing lattice parameters (Ang) [row or column vector]
%   angdeg  vector containing lattice angles (degrees) [row or column vector]
%
% Output:
% -------
%   b       3x3 matrix of the vectors of the reciprocal lattice in Ang^-1
%           expressed in the orthogonal coordinate system attached to the
%           direct lattice with b1 parallel to a. Each column corresponds
%           to the appropriate vector


if max(angdeg)>=180 || min(angdeg)<=0
    error('HORACE:alatt2blatt:invalid_argument', ...
        'some lattice angles bigger than 180 deg or less than 0 deg');
end

if min(alatt)<= 0
    error('HORACE:alatt2blatt:invalid_argument', ...
        'Some lattice parameters are less than 0');
end



cosa   = cosd(angdeg);
sinalp = sind(angdeg(1));


ad = [1,0,0];
bd = [cosa(1),sinalp,0];
cd = [cosa(2)+cosa(1)*cosa(3),sinalp*cosa(3),0];
cd(3) = sqrt(1-cd(1)*cd(1)-cd(2)*cd(2));
abc = [ad;bd;cd];

vol = cross(abc(1,:),abc(2,:))*abc(3,:)';
b1 = 2*pi*cross(abc(2,:),abc(3,:))'/vol/alatt(1);
b2 = 2*pi*cross(abc(3,:),abc(1,:))'/vol/alatt(2);
b3 = 2*pi*cross(abc(1,:),abc(2,:))'/vol/alatt(3);

b=[b1,b2,b3];