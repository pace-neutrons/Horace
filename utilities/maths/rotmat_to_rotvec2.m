function theta = rotmat_to_rotvec2 (rotmat, algorithm)
% Convert rotation matricies to rotation vectors
%
%   >> theta = rotmat_to_rotvec2 (rotmat)
%   >> theta = rotmat_to_rotvec2 (rotmat, algorithm)
%
% Input:
% ------
%   rotmat      Rotation matricies: 3x3 (siugle matrix) or 3 x 3 x m array
%               Relates the components of a vector v expressed in the two
%              coordinate frames by:
%                   v'(i) = R(i,j) v(j)
%
%   algorithm   Method for algorithm
%                 =0  Fast method due to T.G.Perring (default)
%                 =1  Generic method based on matrix exponentiation
%
% Output:
% -------
%   theta       Rotation vector: vector length 3 (single rotation vector)
%              or 3 x m array (m is the number of vectors).
%               A rotation vector defines the orientation of a coordinate frame
%              S' with respect to a frame S by rotation about a unit vector
%              (n(1),n(2),n(3)) in S by angle THETA (in a right-hand sense).
%               This defines a 3-vector:
%                 (THETA(1), THETA(2), THETA(3)) where THETA(i) = THETA*n(i).
%
%               In this function the units are radians.
%
% Note:
%   rotmat_to_rotvec    Rotation vector in degrees
%   rotmat_to_rotvec2   Rotation vector in radians


% Check that rotation matrix has correct size
sz=size(rotmat);
if numel(sz)==2
    nmat=1;
    if sz(1)~=3 || sz(2)~=3
        error('Check size of rotation matrix: must be 3x3 matrix or 3 x 3 x m array')
    end
elseif numel(sz)==3
    nmat=sz(3);
    if sz(1)~=3 || sz(2)~=3 || nmat<0
        error('Check size of rotation matrix: must be 3x3 matrix or 3 x 3 x m array')
    end
else
    error('Check size of rotation matrix: must be 3x3 matrix or 3 x 3 x m array')
end

% Calculate rotation vectors
if nargin==2 && algorithm==1
    % Generic method, but appears to be up to a factor of 100 slower than the default method
    if nmat==1
        tmp=logm(rotmat);
        theta=[tmp(8);tmp(3);tmp(4)];
    else
        theta=zeros(3,nmat);
        for i=1:nmat
            tmp=logm(rotmat(:,:,i));
            theta(:,i)=[tmp(8);tmp(3);tmp(4)];
        end
    end
    
else
    % Fast method, but which may not be so robust at very small theta
    small=1e-20;
    
    S =0.5*(rotmat+permute(rotmat,[2,1,3]));% symmetric component of rotation matrix
    sN=0.5*[(rotmat(2,3,:)-rotmat(3,2,:));(rotmat(3,1,:)-rotmat(1,3,:));(rotmat(1,2,:)-rotmat(2,1,:))];
    % sin(theta)*(n1;n2;n3)
    
    % Get angle of rotation in range 0<=theta<=pi
    costh=0.5*((S(1,1,:)+S(2,2,:)+S(3,3,:))-1);
    absunity=(abs(costh)>1);
    costh(absunity)=sign(costh(absunity));  % catch rounding errors
    theta0=squeeze(acos(costh))';   % make a row vector
    
    % Get unit vector for rotation
    S(1,1,:)=S(1,1,:)-costh;
    S(2,2,:)=S(2,2,:)-costh;
    S(3,3,:)=S(3,3,:)-costh;
    
    Sdiag=squeeze([S(1,1,:);S(2,2,:);S(3,3,:)]);     % matrix made from array of diagonals
    [dummy,icol]=max(Sdiag,[],1);   % indicies of columns with maximum diagonal elements
    Sicol=S(:,icol+3*(0:nmat-1));   % matrix made from columns with largest digonal elements
    vlen=sqrt(sum(Sicol.^2,1));
    theta=Sicol./repmat(vlen,[3,1]);
    ok=(vlen>small);    % those rotation vectors with non-zero rotation
    theta(:,~ok)=0;
    sgn=ones(1,nmat);
    neg=(sN(icol+3*(0:nmat-1))<0);
    sgn(neg)=-1;
    
    % Multiply unit vector by theta and sign
    theta=repmat(theta0.*sgn,[3,1]).*theta;
    
end
