function p=vec_to_cell(pp,np)
% Split a vector into a cell array of vectors
%
%   >> p=vec_to_cell(pp,np)
%
% Use instead of mat2cell as will be faster
%
% Input:
% ------
%   pp      Vector
%   np      Number of elements in each of the output vectors
%          Must have sum(np(:))=numel(pp)
%
% Output:
% -------
%   p       Cell array of vectors. The cell array will have the same
%          shape as pp (i.e. column or row). If pp is a scalar, it is
%          treated as a column vector.
%           Each vector in p will also have the same shape as pp.
%
% If pp was not a vector, then the output is unpredictable.


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


n=numel(np);
if n==1     % catch special case of a single vector
    p={pp};
else
    nend=cumsum(np(:));
    nbeg=nend-np(:)+1;
    if size(pp,2)==1
        p=cell(n,1);
    else
        p=cell(1,n);
    end
    for i=1:n
        p{i}=pp(nbeg(i):nend(i));
    end
end

