function m = cormat(alatt,r_angdeg, varargin)
% Calculates the correction matrix that needs to be applied in case of a
% crystal being misaligned with respect to the expected scattering plane. 
% This matrix is calculated in the  following way (some of this can be 
% found in chapter 2 of Fundamentals of Crystallography by C. Giacovazzo
% (SBN: 0198509588)):
%
% Syntax:
%   >> m=crystal(alatt, r_angdeg, clatt)
%   >> m=crystal(alatt, r_angdeg)
%
% Input:
%-------
%   alatt       vector containing lattice parameters (Ang) and angles (degrees) [row or column vector] with format [a,b,c,aa,bb,cc] 
%   r_angdeg    vector containg the correction rotation angles (degrees) [row or column vector] with format [r1,r2,r3]
%   clatt       vector containing the corrected lattice parameters (Ang) and angles (degrees) [row or column vector]format [a',b',c',aa',bb',cc'] 
%
% Output:
%--------
%   m           Correction matrix
%
% m is calculated as follows:
% Step 1: Define an orthonormal set of vectors within the reciprocal
% lattice basis, such that e1||a*, e3||a*xb* and e2||e3xe1. Here e1, e2, e3
% are unit vectors. We can now relate a vector in reciprocal space to one
% in this new coordinate frame, (x1,x2,x3)=B(a,b,c,aa,bb,cc)(hkl). Here B 
% is the matrix of Busing & Levy (Acta Cryst. 22, 457 (1967)). This will 
% be done using Toby's bmat.m routine.
%
% Step2: This initial rotation frame now gets rotated into the correct
% orientation frame of the crystal by the following set of anti-clockwise 
% rotations. 1) rotate about e1; 2) rotate about the new e2; 3) rotate 
% about the new e3. We are not using Euler's rotation theorem as we assume
% that the rotations will be small. (xc1,xc2,xc3)=R(x1,x2,x3)
%
% Step3: Convert the correct orientation frame back into reciprocal space,
% by applying B'^-1 (taking into account corrections to the lattice
% parameters if need be). (hc,kc,lc)=B'^1(xc1,xc2,xc3),
% B'=B(a',b',c',aa',bb',cc')
%
% (hc,kc,lc)=B'^1RB(hkl)=M(hkl)

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

% Check the input arguments
if nargin<2,
    error('Need to give the initial lattice parameters, rotation angles (and final lattice parameters');
elseif nargin==2,
    if length(alatt)<6 | length(r_angdeg)<3,
        error('Check length of alatt and/or r_angdeg');
    else
        clatt= alatt;
        rrot= [1,2,3]; % rotation sequence: e1,e2',e"
    end
elseif nargin==3,
    if length(alatt)<6 | length(r_angdeg)<3,
        error('Check length of alatt, r_angdeg');
    end
    temp=varargin{1}; % can either be rotation sequence or lattice parameters
    if length(temp)==6,
        clatt= temp;
        rrot= [1,2,3];
    elseif length(temp)==3,
        clat= alatt;
        rrot= temp;
    else
        error('Check input arguments');        
    end
else
    if length(alatt)<6 | length(r_angdeg)<3,
        error('Check length of alatt, r_angdeg');
    end
    rrot= varargin{1};
    clatt= varargin{2};
    if length(rrot)~=3 | length(clatt)~=6,
        error('When given all for arguments the order is alatt,r_angdeg,rrot,clatt');
    else
    end
end

% Calculate the B(a,b,c,aa,bb,cc) matrix
b= bmat(alatt(1:3),alatt(4:6));

% Calculate the rotation matrix r.
r_ang = r_angdeg*(pi/180);
c1= cos(r_ang(1));
s1= sin(r_ang(1));
c2= cos(r_ang(2));
s2= sin(r_ang(2));
c3= cos(r_ang(3));
s3= sin(r_ang(3));

if rrot(1)==1,
    r1= [1,0,0;0,c1,-s1;0,s1,c1]; % rotate about e1
    if rrot(2)==2,
        r2= [c2,0,s2;0,1,0;-s2,0,c2]; % rotate about e2
        r3= [c3,-s3,0;s3,c3,0;0,0,1]; % rotate about e3
    else
        r2= [c2,-s2,0;s2,c2,0;0,0,1]; % rotate about e3
        r3= [c3,0,s3;0,1,0;-s3,0,c3]; % rotate about e2
    end
elseif rrot(1)==2,
    r1= [c1,0,s1;0,1,0;-s1,0,c1]; % rotate about e2
    if rrot(2)==1,
        r2= [1,0,0;0,c2,-s2;0,s2,c2]; % rotate about e1
        r3= [c3,-s3,0;s3,c3,0;0,0,1]; % rotate about e3
    else
        r2= [c2,-s2,0;s2,c2,0;0,0,1]; % rotate about e3
        r3= [1,0,0;0,c3,-s3;0,s3,c3]; % rotate about e1
    end
else
    r1= [c1,-s1,0;s1,c1,0;0,0,1]; % rotate about e3
    if rrot(2)==1,
        r2= [1,0,0;0,c2,-s2;0,s2,c2]; % rotate about e1
        r3= [c3,0,s3;0,1,0;-s3,0,c3]; % rotate about e2
    else
        r2= [c2,0,s2;0,1,0;-s2,0,c2]; % rotate about e2
        r3= [1,0,0;0,c3,-s3;0,s3,c3]; % rotate about e1
    end
end

r=r3*r2*r1;

% Calculate B'(a',b',c',aa',bb',cc')^-1 matrix
b_prime= bmat(clatt(1:3),clatt(4:6));

% Calculate M
m= inv(b_prime)*r*b;