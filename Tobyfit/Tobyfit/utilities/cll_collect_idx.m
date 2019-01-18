% Given a cell index or multiple cell indicies, plus a linked list of
% points/pixels within that/those cell(s), pull together the vector of
% indicies for the contained points/pixels.
% For the Cell Linked-List approach to sorting resolution convolution.

% Inputs:
%       cell        A single cell index or an array of cell indicies.
%
%       head        The head list of the linked list to traverse.
%
%       list        The list of the linked list to traverse.
%
% Outputs:
%       idx         A row vector of indicies collected from the linked list
%
function idx = cll_collect_idx(cell,head,list)
% Assume we have multiple cells to check. We could specialize to the single
% cell case, but the speed diferences should be small.
n = numel(cell);
% Before we can allocate our output index vector, we need to know how many
% pixels/points are in each cell
len = zeros(1,n);
for i=1:n
    len(i) = number_in_cell(head,list,cell(i));
end
% Allocate output row vector for all point/pixel indicies
idx = zeros(1, sum(len));

% For each cell, we will need to know its first and last index into
% the output vector. Note that in the case of a len(i)==0, the
% corresponding entries into begin_end will just be repeated and therefore
% there is nothing to worry about
% (e.g., len = [5,0,3,...] gives begin_end = [0,5,5,8,...] )
begin_end = cat(2, 0, cumsum(len) );
% It is very common for cell(s) to contain no pixels/points, so we might
% save time by not looping over the empty cells:
notempty = find(len>0,n);
% For each not-empty cell
for i=1:numel(notempty)
    % Get the first index into list, this is also the first output index
    k=head( cell(notempty(i)) );
    % From the first to last index into the output for this cell
    for j= 1+begin_end(notempty(i)) : begin_end(notempty(i)+1)
        % Set the output index
        idx(j) = k;
        % And get the next index from our linked list
        k = list(k);
    end
end
end

function no = number_in_cell(head,list,i)
% Count the number of linked-list entries within cell i
no = 0;
i=head(i);
while i~=0
    no = no +1;
    i = list(i);
end
end
