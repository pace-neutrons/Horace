function w = plus (w1, w2)
% Implement w1 + w2 for 3D datasets
%
%   >> w = w1 + w2
%
%   If w1, w2 are datasets of the same size:
%       the operation is performed element-by-element
%   if one of w1 or w2 is a double:
%        - if a scalar, apply to each element of the dataset
%        - if an array of the same size as the signal array, apply element by element
%
%   w1, w2 can be arrays:
%       - an array of 4D datasets
%       - an n-dimensional array of size, of which the inner 4 dimensions will be
%         combined element by element with the 4D dataset, and the outer (n-4) must
%         match the array size of the 4D dataset array

w = dnd_binary_op(w1,w2,@single_plus,'d4d',4);