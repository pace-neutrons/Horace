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
nX = prod(sX(2:end));

if any(size(minX)~=[d,1])||any(size(maxX)~=[d,1])||any(size(delX)~=[d,1]) ...
   ||~isnumeric(minX)||~isnumeric(maxX)||~isnumeric(delX)||~isnumeric(X)
    error('Check that input minX, maxX, delX have same dimentionality (%d) as X',d)
end

if nargin < 5 || isempty(span) || nargin<6 || isempty(N)
    % get the span along each dimension and the number of cells along each axis
    [span,N]=cll_cell_span(minX,maxX,delX);
end

Ntot = prod(N); % the *total* number of cells

head = zeros(Ntot,1); % initialize the head to zeros
list = zeros(nX,1); % and the linked list too

% % If N is ceil( (maxX-minX)./delX) ) + 1, then the first bin is centered at
% % minX (and the last at maxX). In the code below, we need to shift from
% % edge indexing to center indexing with a bin_shfit of 0.5
% bin_shift = 0.5;

% If instead N is ceil( (maxX-minX)./delX ), then the first bin has its
% corner at minX. In this case, no shift is needed.
bin_shift = 0;

for i=1:nX
    % Determine the index along each of the d dimensions:
    %   X(:,i)-minX     gives the vector from the minimum corner
    %   ./delX          makes this a number of delX bins along each direction
    id = floor( (X(:,i)-minX)./delX +bin_shift ); 
    % ensure we assign out-of-bound points to the closest-outermost-bin
    oob1 = id < 0;
    oob2 = id > N-1;
    if any(oob1); id( oob1 ) = 0; end           % minimum index 0
    if any(oob2); id( oob2 ) = N( oob2 )-1; end % maximum index N-1
    % switch from multi-dimensional 0-based indexing to 1-based linear indexing
    idx = 1 + sum(id.*span);
    % and finally insert this index into the linked list
    list(i) = head(idx); % put the index of the last point in this cell, in the list at this point's index
    head(idx) = i; % put this point's index in the cell index of the head list.
end

end