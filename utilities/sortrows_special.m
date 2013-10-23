function [y,ndx] = sortrows_special(x,col)
%SORTROWS Sort rows in ascending order.
%   Y = SORTROWS(X) sorts the rows of the matrix X in ascending order as a
%   group. X is a 2-D numeric or char matrix. For a char matrix containing
%   strings in each row, this is the familiar dictionary sort.  When X is
%   complex, the elements are sorted by ABS(X). Complex matches are further
%   sorted by ANGLE(X).  X can be any numeric or char class. Y is the same
%   size and class as X.
%
%   SORTROWS(X,COL) sorts the matrix based on the columns specified in the
%   vector COL.  If an element of COL is positive, the corresponding column
%   in X will be sorted in ascending order; if an element of COL is negative,
%   the corresponding column in X will be sorted in descending order. For 
%   example, SORTROWS(X,[2 -3]) sorts the rows of X first in ascending order 
%   for the second column, and then by descending order for the third
%   column.
%
%   [Y,I] = SORTROWS(X) and [Y,I] = SORTROWS(X,COL) also returns an index 
%   matrix I such that Y = X(I,:).
%
%   Notes
%   -----
%   SORTROWS uses a stable version of quicksort.  NaN values are sorted
%   as if they are higher than all other values, including +Inf.
%
%   Class support for input X:
%      numeric, logical, char
%
%   See also SORT, ISSORTED.
%
% NB Modified for use with shoelace rebinning by RAE. Get rid of some of
% the error checking, as this is causing slowdowns

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision$  $Date$

% I/O details
% -----------
% X    - 2-D matrix of any type for which SORT works.
%
% COL  - Vector.  Must contain integers whose magnitude is between 1 and size(X,2).
%        May be any numeric class.
%
% Y    - 2-D matrix. Same size and class as X.
%
% NDX  - Column vector of size M-by-1, where M is size(X,1).  Double.
%        Contains row indices into X.

% error(nargchk(1,2,nargin,'struct'))
% if ndims(x) > 2
%     error('MATLAB:SORTROWS:inputDimensionMismatch','X must be a 2-D matrix.');
% end

% n = size(x,2);

% if nargin < 2
%     x_sub = x;
%     col = 1:n;
% else
%     if isnumeric(col)
        col = double(col);
%     else
%         error('MATLAB:sortrows:COLnotNumeric', 'COL must be numeric.');
%     end
%     if ( ~isreal(col) || numel(col) ~= length(col) ||...
%             any(floor(col) ~= col) || any(abs(col) > n) || any(col == 0) )
%         error('MATLAB:sortrows:COLmismatchX',...
%             'COL must be a vector of column indices into X.');
%     end

    x_sub = x(:, abs(col));
% end

% if isreal(x) && ~issparse(x) && n > 3
%     % Call MEX-file to do the hard work for non-sparse real
%     % and character arrays.  Only called if at least 4 elements per row.
%     ndx = sortrowsc(x_sub, col);
% 
% elseif isnumeric(x) && ~isreal(x) && ~issparse(x)
%     % sort_complex implements the specified behavior of using ABS(X) as
%     % the primary key and ANGLE(X) as the secondary key.
%     ndx = sort_complex(x_sub, col);
% 
% elseif issparse(x)
%     %  We'll use the old sortrows algorithm for sparse.
%     ndx = sort_sparse(x_sub, col);

% else
    % For sparse arrays, cell arrays, and anything else for which the
    % sortrows worked MATLAB 6.0 or earlier, use the old MATLAB 6.0
    % algorithm.  Also called if 3 or fewer elements per row.
%     if iscell(x)
%         ndx = sort_cell_back_to_front(x_sub, col);
%     else
        ndx = sort_back_to_front(x_sub, col);
%     end
% end

% Rearrange input rows according to the output of the sort algorithm.
y = x(ndx,:);

% If input is 0-by-0, make sure output is also 0-by-0.
% if isequal(size(x),[0 0])
%     y = reshape(y,[0 0]);
%     ndx = reshape(ndx,[0 0]);
% end

%--------------------------------------------------
function ndx = sort_back_to_front(x, col)
% NDX = SORT_BACK_TO_FRONT(X, COL) sorts the rows of X by sorting each
% column from back to front.  This is the sortrows algorithm used in MATLAB
% 6.0 and earlier.

[m,n] = size(x);
ndx = (1:m)';
for k = n:-1:1
    if (col(k) < 0)
        [ignore,ind] = sort(x(ndx,k),'descend');
    else
        [ignore,ind] = sort(x(ndx,k),'ascend');
    end
    ndx = ndx(ind);
end

%--------------------------------------------------
function ndx = sort_cell_back_to_front(x, col)
% Descending version for cells
[m,n] = size(x);
ndx = (1:m)';

for k = n:-1:1
    tmp = char(x(ndx,k));
    ind = sortrowsc(tmp, sign(col(k))*(1:size(tmp,2)));
    ndx = ndx(ind);
end


%--------------------------------------------------
function ndx = sort_complex(x, col)
% NDX = SORT_COMPLEX(X, COL) sorts the rows of the complex-valued matrix X.
% Individual elements are sorted first by ABS() and then by ANGLE().

[m,n] = size(x);
xx = zeros(m,2*n);
xx(:,1:2:end) = abs(x);
xx(:,2:2:end) = angle(x);
cc = zeros(2*numel(col),1);
cc(1:2:end) = col(:);
cc(2:2:end) = col(:);

ndx = sortrowsc(xx,cc);

%--------------------------------------------------
function ndx = sort_sparse(x, col)
% NDX = SORT_SPARSE(X, COL) sorts the rows of X by sorting each column
% from back to front.  This is the sortrows algorithm used in MATLAB 6.0
% and earlier.  We have a separate function for sparse since sort does not
% yet accept a mode argument for sparse matrices.

[m,n] = size(x);
ndx = (1:m)';
bLogical = islogical(x);
bChar = ischar(x);
for k = n:-1:1
    if (col(k) < 0)
        if bLogical
            [ignore,ind] = sort(1-uint8(x(ndx,k)));
        elseif bChar
            [ignore,ind] = sort(intmax('uint16')-uint16(x(ndx,k)));
        else
            [ignore,ind] = sort(-x(ndx,k));
        end
    else
        [ignore,ind] = sort(x(ndx,k));
    end
    ndx = ndx(ind);
end
