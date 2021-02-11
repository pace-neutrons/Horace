function orth = normal4D(three_vector)
% function calculates the vector, orthogonal to 4-D plain defining by 3
% input vectors.
%
% Input: 
% three_vector -- 4x3 or 4x4 array defining three non-parallel vectors lying in
%                 hyperplain in 4D. The x,y,z,t coordinates of each vector
%                 are propagating along first dimension (column).
%                 if there are 4 input vectors, they define the hyperplain,
%                 passing through these points
% Output:
% normal      [4x1] array, describing the vector, which is orthogonal to
%             three input vectors and  the hyperplain they define.
%
%
if ~(all(size(three_vector)==[4,3]) || all(size(three_vector)==[4,4]))
    error('ORHTO_4D:invalid_argument',...
        ['Input has to be a 4x3 or 4x4 array,',...
        ' describing 3 4D vectors or 4 4D poings, defining hyperplain in 4D\n',...
        ' Actual size is: %s'],evalc('disp(size(three_vector))'))
end

if size(three_vector,2)==4
    three_vector = three_vector(:,1:3)-three_vector(:,4);
end

orth = zeros(4,1);
orth(1) =  det(three_vector(2:4,:)');
orth(2) = -det([three_vector(1,:);three_vector(3:4,:)]');
orth(3) =  det([three_vector(1:2,:);three_vector(4,:)]');
orth(4) = -det(three_vector(1:3,:)');
% make first step of Gramm-Smith othogonalization (is it done properly?):
norm = sqrt(orth'*orth);
if norm<1.e-12
    error('ORHTO_4D:invalid_argument',...
        'Some or all vectors, describing the hyperplain are parallel')
end
orth = orth/norm;

i=1:3;
n3 = arrayfun(@(nv)(sqrt(three_vector(:,nv)'*three_vector(:,nv))),i,...
    'UniformOutput',true);
e33 = three_vector./repmat(n3,4,1);
orth = orth -sum(e33.*(orth'*three_vector),2);

orth = orth/sqrt(orth'*orth);