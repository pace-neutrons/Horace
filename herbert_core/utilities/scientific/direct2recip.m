function [b,varargout] = direct2recip(alatt, angdeg)
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
% Optional: (if requested)
%  b_norm   3-vector of the length of the reciprocal lattice vectors in
%           units of 2*p/lengs of direct lattice
%  rlu_angl 3-vector of angles between the vectors of reciprocal lattice
%  dir_mat  3x3 matrix of the coordinates of the vectors of the
%           direct lattice in the orthogonal coordinate system attached to
%           the direct lattice
%

if max(angdeg)>=180 || min(angdeg)<=0
    error('HORACE:alatt2blatt:invalid_argument', ...
        'some lattice angles bigger than 180 deg or less than 0 deg');
end

if min(alatt)<= 0
    error('HORACE:alatt2blatt:invalid_argument', ...
        'Some lattice parameters are less than 0');
end



cosa   = cosd(angdeg);
singa = sind(angdeg(3));


ad = [1,0,0];
bd = [cosa(3),singa,0];
cd = [cosa(2),(cosa(1) - cosa(2)*cosa(3))/singa,0];
cd(3) = sqrt(1-cd(1)*cd(1)-cd(2)*cd(2));
abc = [ad;bd;cd];

inv_vol = 2*pi/(cross(abc(1,:),abc(2,:))*abc(3,:)');
b1 = cross(abc(2,:),abc(3,:))'*inv_vol/alatt(1);
b2 = cross(abc(3,:),abc(1,:))'*inv_vol/alatt(2);
b3 = cross(abc(1,:),abc(2,:))'*inv_vol/alatt(3);

b=[b1,b2,b3];

if nargout>1
    varargout{1} = [norm(b1),norm(b2),norm(b3)];
end
if nargout>2
    bn = varargout{1};
    varargout{2} = ...
        [...
        acosd(b2'*b3/bn(2)/bn(3)),...
        acosd(b1'*b3/bn(1)/bn(3)),...
        acosd(b1'*b2/bn(1)/bn(2))];
end
if nargout >3
    varargout{3}  = abc';
end