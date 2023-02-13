function [min_ind,max_ind] = convert_ind_to_blocks(indices)
%convert linear sorted indexes into ranged form i.e,
% min-max indexes with step 1
%
% the operation is opposite to indexing e.i if one provides input array
% a:b, the routine retuns [a, pair
%

range_ind= find(diff(indices(:)')>1);
min_ind = [indices(1),indices(range_ind+1)];
max_ind = [indices(range_ind),indices(end)];
