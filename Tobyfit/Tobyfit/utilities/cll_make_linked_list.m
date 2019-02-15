% For a list of points, plus cell information, determine which cell each
% point goes into and return the information as a linked list.

% Inputs:
%   X       The points to be put into cells. (d,nX)
%   minX    The minimum corner of all cells. (d,1)
%   maxX    The maximum corner of all cells. (d,1)
%   delX    The widths of each cell. (d,1)
%
% Outputs:
%   head    The head of the linked list, with Ncells elements
%   list    The list of the linked list, with nX elements
function [head,list] = cll_make_linked_list(X,minX,maxX,delX,span,N)
% Input Validation
sX = size(X);
d = sX(1);
if any(size(minX)~=[d,1])||any(size(maxX)~=[d,1])||any(size(delX)~=[d,1]) ...
   ||~isnumeric(minX)||~isnumeric(maxX)||~isnumeric(delX)||~isnumeric(X)
    error('Check that input minX, maxX, delX have same dimentionality (%d) as X',d)
end

if nargin < 5 || isempty(span) || nargin<6 || isempty(N)
    % get the span along each dimension and the number of cells along each axis
    [span,N]=cll_cell_span(minX,maxX,delX);
end

idx = cll_cell_idx(X,minX,maxX,delX,span,N);
[head,list]=make_linked_list(prod(N),numel(idx),idx);
end

function [head,list]=make_linked_list(nh,nl,idx)
head = zeros(nh,1);
list = zeros(nl,1);
for i=1:nl
    list(i) = head(idx(i));
    head(idx(i)) = i;
end
end