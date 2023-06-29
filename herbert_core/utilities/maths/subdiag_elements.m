function [vector, index] = subdiag_elements(mat)
%SUBDIAG_ELEMENTS returns elements of the a square matrix which located below the 
%matrix diagonal
%
% Inputs:
% mat    -- square 2D matrix.
% Outputs:
% vector -- vector containing elements located under main diagonal of the matrix
% index  -- the linear indexes of these elements in the input matrix if matrix is treated
%           as 1D matrix. Use ind2sub to convert these indexes into 2D indexes
%
% Example:
%>> mat = [1,2,3;
%          4,5,6;
%          7,8,9];
%>> [lw,ind] = subdiag_elements(mat)
%>> lw   = [4; 7; 8]
%>> ind =  [4; 7; 8]

sz = size(mat);
if numel(sz) ~=2 || sz(1) ~= sz(2)
    error('HERBERT:utilities:invalid_argument',...
        'Input value must be a square matrix. In fact, its size is: %s', ...
        disp2str(sz));
end
i = 1:sz(1);
j = i;
%j = j(j<i);
[i,j] = meshgrid(i,j);
select = j(:)<i(:);
index = sub2ind(sz,i(select),j(select));
vector = mat(index);
