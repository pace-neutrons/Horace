function normal = normal4D(three_vector)
% function calculates the vector, orthogonal to 4-D plain defining by 3
% input vectors.
%
% Input: 
% three_vector -- 4x3 array defining three non-parallel vectors lying in
%                 hyperplain in 4D. The x,y,z,t coordinates of each vector
%                 are propagating along first dimension (column)
% Output:
% normal      [4x1] array, describing the vector, which is orthogonal to
%             three input vectors and  the hyperplain they define.
%

normal = zeros(4,1);
normal(1) =  det(three_vector(2:4,:)');
normal(2) = -det([three_vector(1,:);three_vector(3:4,:)]');
normal(3) =  det([three_vector(1:2,:);three_vector(4,:)]');
normal(4) = -det(three_vector(1:3,:)');
