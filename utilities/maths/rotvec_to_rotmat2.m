function rotmat = rotvec_to_rotmat2 (theta)
% Convert rotation vectors to rotation matricies
%
%   >> rotmat = rotvec_to_rotmat2 (theta)
%
%   theta   Rotation vector: vector length 3 (single rotation vector) or 3 x m array (m vectors)
%           Coordinate frame S' is related to S by rotation about a unit vector (n(1),n(2),n(3))
%           in S by angle THETA in radians (in a right-hand sense). This defines a 3-vector
%           (THETA(1), THETA(2), THETA(3)) where THETA(i) = THETA*n(i).
%
%   rotmat  Rotation matricies: 3x3 (single matrix) or 3 x 3 x m array
%           Relates the components of a vector v expressed in the two coordinate frames by
%               v'(i) = R(i,j) v(j)
%
% Differs from rotvec_to_rotmat in the units of theta (here radians, there degrees)

if numel(theta)==3
    rotmat=expm([0,theta(3),-theta(2); -theta(3),0,theta(1); theta(2), -theta(1), 0]);
else
    sz=size(theta);
    if numel(sz)==2 && sz(1)==3 && sz(2)>1
        gen=zeros(9,sz(2));
        gen([6,7,2],:)=-theta;
        gen([8,3,4],:)=theta;
        gen=reshape(gen,[3,3,sz(2)]);
        rotmat=zeros([3,3,sz(2)]);
        for i=1:sz(2)
            rotmat(:,:,i)=expm(gen(:,:,i));
        end
    else
        error('Check size of input argument')
    end
end
