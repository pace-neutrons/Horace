function [ok,mess,ix,perm] = is_integer_id(id_in)
% Check that identifiers are unique, and return indexing array
%
%   >> [ok,mess,ix,perm] = is_integer_id(id)
%
% Input:
% ------
%   id      Input index array
%
% Output:
% -------
%   ok      True if indicies are unique, false if not
%   mess    Message if not OK; empty string if ok
%   ix      Indexing array (column vector)
%           If already sorted in ascending order, ix = []
%           If not, ix is such that id_in(ix) is sorted in ascending order
%   perm    True if id is a permutation of the integers 1:numel(id)

id = id_in(:);

ok = true;
mess = '';

% Check inputs are integers
if all(id>=1) && all(rem(id,1)==0)
    % Determine if already sorted
    if issorted(id)
        ix = [];
        perm = (id(1)==1 && id(end)==numel(id));
    elseif issorted(flipud(id))
        ix = (numel(id):-1:1)';
        perm = (id(end)==1 && id(1)==numel(id));
    else
        [id,ix] = sort(id);
        perm = (id(1)==1 && id(end)==numel(id));
    end
    
    % Check if unique identifiers
    if any(diff(id)==0)
        ok = false;
        mess = 'identifiers must be unique';
        ix = [];
        perm = false;
    end
else
    ok = false;
    mess = 'identifiers must have integer values and be greater than zero';
    ix = [];
    perm = false;
end
