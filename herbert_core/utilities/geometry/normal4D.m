function orth = normal4D(three_vector)
% Calculate the vector, orthogonal to 4-D plain defined by 3
% input 4D vectors, or 4 points in 4D
%
% Input:
% three_vector -- 4x3 or 4x4 array defining three non-parallel vectors lying in
%                 hyper-plain in 4D. The x,y,z,t coordinates of each vector
%                 are propagating along first dimension (column).
%                 if input is a 4x4 array, the data define the hyper-plain,
%                 passing through four 4D points.
% Output:
% orth    --   [4x1] array describing the vector which is orthogonal to
%              three input vectors and the hyper-plain they define.
%
%
if ~(all(size(three_vector)==[4,3]) || all(size(three_vector)==[4,4]))
    error('ORTHO_4D:invalid_argument',...
        ['Input has to be a 4x3 or 4x4 array,',...
        ' describing 3 4D vectors or 4 4D points, defining hyper-plain in 4D\n',...
        ' Actual size is: %s'],evalc('disp(size(three_vector))'))
end

if size(three_vector,2)==4
    % reduce case of 4 points to 3 vectors by moving the centre of coordinates
    % into the forth point.
    three_vector = three_vector(:,1:3)-three_vector(:,4);
end

orth = zeros(4,1);
orth(1) =  det(three_vector(2:4,:)');
orth(2) = -det([three_vector(1,:);three_vector(3:4,:)]');
orth(3) =  det([three_vector(1:2,:);three_vector(4,:)]');
orth(4) = -det(three_vector(1:3,:)');
% make first step of Gramm-Smith orthogonalization (is it done properly?):
norm = sqrt(orth'*orth);
if norm<1.e-12
    error('ORTHO_4D:invalid_argument',...
        'Some or all vectors, describing the hyper-plain are parallel or zero length')
end
orth = orth/norm;

% calculate the norms for all 3 input vectors.
i=1:3;
n3 = arrayfun(@(nv)(sqrt(three_vector(:,nv)'*three_vector(:,nv))),i,...
    'UniformOutput',true);
% normalise input wectors to get unit size vectors
e33 = three_vector./repmat(n3,4,1);
% extract the projections of the input vectors from the resulting vector
orth = orth -sum(e33.*(orth'*three_vector),2);

% renormalize result to unity
orth = orth/sqrt(orth'*orth);