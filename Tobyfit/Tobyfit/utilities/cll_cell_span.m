% For the Cell Linked-List approach to sorting resolution convolution.
% Given the minimum and maximum corners of the total resolution bounding
% box and the dimensions of a single cell, calculate the total number of
% cells along each axis and the span for each axis.

% Inputs:
%       minX        the minimum corner of all resolution ellipsoids, this
%                   can be (1,d), (d,1), or (n,m) with n*m=d.
%
%       maxX        the maximum corner of all resolution ellipsoids,
%                   allowable dimensions are the same as minX
%
%       delX        the dimensions of a single cell, this should ideally be
%                   related to the maximum dimensions of a single
%                   resolution ellipsoid. Allowable dimensions like minX.
%
% Outputs:
%       N           A (d,1) vector with the number of cells along each axis
%                   such that cell with subscripted indicies [1,1,1,...] 
%                   has its minimum corner equal to minX, and the cell with
%                   subscripted indicies N has maxX somewhere between its
%                   minimum and maximum corners.
%
%       span        The span of each dimension. In a zero-based indexing
%                   system the linear index of a cell is the sum of the
%                   elementwise multiplication of the span and the
%                   subscripted index of the cell.
function [span,N] = cll_cell_span(minX,maxX,delX)
d=numel(minX);
if numel(maxX)~=d || numel(delX)~=d; error('All inputs must be the same size'); end
if size(minX,1)~=d; minX=minX(:); end
if size(maxX,1)~=d; maxX=maxX(:); end
if size(delX,1)~=d; delX=delX(:); end

N = ceil( (maxX-minX)./delX );  % the number of cells along each axis
span = cumprod([1;N(1:end-1)]); % the span of each dimension
end