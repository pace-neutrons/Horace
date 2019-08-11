function rotmat = rotvec_to_rotmat2 (theta, algorithm)
% Convert rotation vectors to rotation matricies
%
% The rotation matrix relates the components of a vector expressed in a
% coordinate frame S to those in a frame S' that is obtained from S by the
% rotation vector (whose components are given in S). The relationship is
% v'(i) = R(i,j) v(j).
%
%   >> rotmat = rotvec_to_rotmat2 (theta)
%   >> rotmat = rotvec_to_rotmat2 (theta, algorithm)
%
% Input:
% ------
%   theta       Rotation vector or set of rotation vectors:
%               Vector length 3 , or 3 x m array, where m is the number of vectors
%               A rotation vector defines the orientation of a coordinate frame
%              S' with respect to a frame S by rotation about a unit vector
%              (n(1),n(2),n(3)) in S by angle THETA (in a right-hand sense).
%               This defines a 3-vector:
%                 (THETA(1), THETA(2), THETA(3)) where THETA(i) = THETA*n(i).
%
%               In this function the units are radians.
%
%   algorithm   Method for algorithm
%                 =0  Fast method due to T.G.Perring (default)
%                 =1  Generic method based on matrix exponentiation
%
% Output:
% -------
%   rotmat      Rotation matrix or set of rotation matricies: 3 x 3 x m array
%               Relates the components of a vector v expressed in the
%              two coordinate frames by:
%                   v'(i) = R(i,j) v(j)
%
% Note:
%   rotvec_to_rotmat    Rotation vector in degrees
%   rotvec_to_rotmat2   Rotation vector in radians


% Check that rotation vector has correct size; make a single vector a column
sz=size(theta);
if numel(sz)==2
    if numel(theta)==3
        nvec=1;
        if sz(1)==1, theta=theta'; end
    elseif sz(1)==3 && sz(2)>=1
        nvec=sz(2);
    else
        error('Check size of rotation vector: must be vector length 3 or 3 x m array')
    end
else
    error('Check size of rotation vector: must be vector length 3 or 3 x m array')
end

% Calculate rotation matricies
if nargin==2 && algorithm==1
    % Generic method, but appears to be up to a factor of 100 slower than the default method
    if nvec==1
        rotmat=expm([0,theta(3),-theta(2); -theta(3),0,theta(1); theta(2), -theta(1), 0]);
    else
        gen=zeros(9,nvec);
        gen([6,7,2],:)=-theta;
        gen([8,3,4],:)=theta;
        gen=reshape(gen,[3,3,nvec]);
        rotmat=zeros([3,3,nvec]);
        for i=1:nvec
            rotmat(:,:,i)=expm(gen(:,:,i));
        end
    end
    
else
    % Fast method, but which may not be so robust at very small theta
    small=1e-20;
    
    rotmat=zeros(3,3,nvec);         % pre-allocate
    
    theta0=sqrt(sum(theta.^2,1));	% length of vectors
    ok=theta0>small;
    
    if any(ok)
        nv=theta(:,ok)./repmat(theta0(ok),3,1); % unit vector in S; this line fails if ~any(ok)
        c = cos(theta0(ok));
        s = sin(theta0(ok));
        a = 1 - c;
        rotmat(1,1,ok) = a.*nv(1,:).*nv(1,:) + c;
        rotmat(2,1,ok) = a.*nv(1,:).*nv(2,:) - s.*nv(3,:);
        rotmat(3,1,ok) = a.*nv(1,:).*nv(3,:) + s.*nv(2,:);
        rotmat(1,2,ok) = a.*nv(2,:).*nv(1,:) + s.*nv(3,:);
        rotmat(2,2,ok) = a.*nv(2,:).*nv(2,:) + c;
        rotmat(3,2,ok) = a.*nv(2,:).*nv(3,:) - s.*nv(1,:);
        rotmat(1,3,ok) = a.*nv(3,:).*nv(1,:) - s.*nv(2,:);
        rotmat(2,3,ok) = a.*nv(3,:).*nv(2,:) + s.*nv(1,:);
        rotmat(3,3,ok) = a.*nv(3,:).*nv(3,:) + c;
    end
    rotmat(1,1,~ok) = 1;
    rotmat(2,2,~ok) = 1;
    rotmat(3,3,~ok) = 1;
    
end
