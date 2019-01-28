% Given the speicifications for a set of cells and the index of a central
% cell, determine the indicies of all neighbouring cells.
% For the Cell Linked-List approach to sorting resolution convolution.

% Inputs:
%       centre      The linear index of the central cell for which we are
%                   to determine its neighbours.
%
%       N           A (d,1) vector with the number of cells along each axis
%                   such that cell with subscripted indicies [1,1,1,...] 
%                   has its minimum corner equal to minX, and the cell with
%                   subscripted indicies N has maxX somewhere between its
%                   minimum and maximum corners. As determined by
%                   cll_cell_span.m
%
%       span        The span of each dimension. In a zero-based indexing
%                   system the linear index of a cell is the sum of the
%                   elementwise multiplication of the span and the
%                   subscripted index of the cell. As determined by
%                   cll_cell_span.m
%
%       Ntot        The total number fo cells
%
%       from        Either 0 for 0-based indexing or 1 for 1-based indexing
%                   By default, from=1 to be consistent with MATLAB-like
%                   array indexing.
%
% Outputs:
%       nC          The linear indicies of all neighbouring cells to centre
%                   This vector has been checked to ensure no neighbour
%                   cells are outside of the total cell boundaries.
function nC = cll_cell_neighbours(centre,N,span,Ntot,from)
if nargin<5 || isempty(from)
    from = 1; % By default we're working with MATLAB indexing
end
if nargin<4 || isempty(Ntot)
    Ntot = prod(N);
end
if nargin<3 || isempty(span)
    span = [1; cumprod(N(:))];
    span = span(1:end-1);
end

% The dimensionality of our cells
d = numel(span);
n = numel(centre);
% Switch centre from linear indexing to subscript indexing
c_sub = cll_lin2sub(centre,N,span,Ntot,from); % this is (d,n)


% c_sub is now [i;j;...], the neighbours of which are [i-1;j;...],
% [i+1;j;...], [i;j-1;...], [i;j+1;...], [i-1;j-1;...], [i+1;j-1;...] etc. 
% i.e., they are c_sub plus [-1;0;...], [1;0;...], [0;-1;...], [0;1;...],
% [-1;-1;...], [1;-1;...], [-1;1;...], [1;1;...].
% The vectors added to the center subscripted indicies are the generalized
% d-dimensional body/face/corner diagonals.

% Generate/lookup the diagonals. corners.m includes zeros(d), which is
% fine here since we should include the centre cell within the list of
% neighbours.
ad = permute( fastcorners(d), [2,3,1] ); % (d,1,3^d)
% The neighbour subscripted indicies are just c_sub plus the diagonals
n_sub = reshape( bsxfun(@plus,c_sub,ad), d, n*3^d ); % (d,n,3^d) -> (d,n*3^d)

% It's important that we check to make sure no neighbours have indicies
% outside of all cells, such neighbours do not exist and need to be removed
% from the neighbours list.
% Out of bounds subscript indicies are less than the minimum index or 
% greater than N-1 plus the minimum index. For zero-based indexing these
% are 0 and N-1, respectively; while for one-based indexing they are 1 and
% N, respectively.
oob = any( n_sub < from, 1) | any( n_sub > (N+from-1), 1); % Mixing scalar (<) and elementwise (>) comparison
n_sub=n_sub(:,~oob); % keep only not out of bounds neighbours

% Convert neighbour subscript indicies back to linear indicies
% HINT: sum(span.*subidx) only works for 0-based indexing. If we're using
% 1-based indexing we must subtract and then re-add this first.
nC = sum(bsxfun(@times,span,n_sub-from),1)+from; % (d,1) * (d,d^3) -> (1,d^3)

% Finally, make sure we're only keeping unique neighbour cell indicies
nC = unique(nC);
end

function fc = fastcorners(D)
switch D
    case 3
        fc = [  -1    -1    -1
                -1    -1     0
                -1    -1     1
                -1     0    -1
                -1     0     0
                -1     0     1
                -1     1    -1
                -1     1     0
                -1     1     1
                 0    -1    -1
                 0    -1     0
                 0    -1     1
                 0     0    -1
                 0     0     0
                 0     0     1
                 0     1    -1
                 0     1     0
                 0     1     1
                 1    -1    -1
                 1    -1     0
                 1    -1     1
                 1     0    -1
                 1     0     0
                 1     0     1
                 1     1    -1
                 1     1     0
                 1     1     1];
    case 4
        fc = [  -1    -1    -1    -1
                -1    -1    -1     0
                -1    -1    -1     1
                -1    -1     0    -1
                -1    -1     0     0
                -1    -1     0     1
                -1    -1     1    -1
                -1    -1     1     0
                -1    -1     1     1
                -1     0    -1    -1
                -1     0    -1     0
                -1     0    -1     1
                -1     0     0    -1
                -1     0     0     0
                -1     0     0     1
                -1     0     1    -1
                -1     0     1     0
                -1     0     1     1
                -1     1    -1    -1
                -1     1    -1     0
                -1     1    -1     1
                -1     1     0    -1
                -1     1     0     0
                -1     1     0     1
                -1     1     1    -1
                -1     1     1     0
                -1     1     1     1
                 0    -1    -1    -1
                 0    -1    -1     0
                 0    -1    -1     1
                 0    -1     0    -1
                 0    -1     0     0
                 0    -1     0     1
                 0    -1     1    -1
                 0    -1     1     0
                 0    -1     1     1
                 0     0    -1    -1
                 0     0    -1     0
                 0     0    -1     1
                 0     0     0    -1
                 0     0     0     0
                 0     0     0     1
                 0     0     1    -1
                 0     0     1     0
                 0     0     1     1
                 0     1    -1    -1
                 0     1    -1     0
                 0     1    -1     1
                 0     1     0    -1
                 0     1     0     0
                 0     1     0     1
                 0     1     1    -1
                 0     1     1     0
                 0     1     1     1
                 1    -1    -1    -1
                 1    -1    -1     0
                 1    -1    -1     1
                 1    -1     0    -1
                 1    -1     0     0
                 1    -1     0     1
                 1    -1     1    -1
                 1    -1     1     0
                 1    -1     1     1
                 1     0    -1    -1
                 1     0    -1     0
                 1     0    -1     1
                 1     0     0    -1
                 1     0     0     0
                 1     0     0     1
                 1     0     1    -1
                 1     0     1     0
                 1     0     1     1
                 1     1    -1    -1
                 1     1    -1     0
                 1     1    -1     1
                 1     1     0    -1
                 1     1     0     0
                 1     1     0     1
                 1     1     1    -1
                 1     1     1     0
                 1     1     1     1];
    otherwise
        fc = corners(N);
end
end
