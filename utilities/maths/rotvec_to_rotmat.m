function rotmat = rotvec_to_rotmat (theta)
% Convert rotation vectors to rotation matricies
%
%   >> rotmat = rotvec_to_rotmat (theta)
%
%   theta   Rotation vector: 3 x m array
%           Coordinate frame S' is related to S by rotation about a unit vector (n(1),n(2),n(3))
%           in S by angle THETA in degrees (in a right-hand sense). This defines a 3-vector
%           (THETA(1), THETA(2), THETA(3)) where THETA(i) = THETA*n(i).
%
%   rotmat  Rotation matricies: 3 x 3 x m array
%           Relates the components of a vector v expressed in the two coordinate frames by
%               v'(i) = R(i,j) v(j)

small=1e-20;

theta0=sqrt(sum(theta.^2,1));       % length of vectors
ok=theta0>small;
nv=theta(:,ok)./repmat(theta0(ok),3,1);   % unit vector in S

rotmat=zeros(3,3,numel(theta0));    % pre-allocate

c = cosd(theta0(ok));
s = sind(theta0(ok));
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

rotmat(1,1,~ok) = 1;
rotmat(2,2,~ok) = 1;
rotmat(3,3,~ok) = 1;
