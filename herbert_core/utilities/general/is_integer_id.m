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

% empty id_in will crash the all(id>=1) below
if isempty(id_in)
    ok = false;
    mess = 'HERBERT:is_integer_id:invalid_argument';
    return;
end

id = id_in(:);

ok = true;
mess = '';

% Check inputs are positive integers
if all(id>=1) && all(rem(id,1)==0)
    % Determine if already sorted
    if issorted(id)
        ix = [];
        perm = (id(1)==1 && id(end)==numel(id));
    elseif issorted(flipud(id)) % reverse direction sorted
        ix = (numel(id):-1:1)'; % column vector of descending contiguous sequence
        perm = (id(end)==1 && id(1)==numel(id));% check perm goes from N to 1
    else
        [id,ix] = sort(id);
        perm = (id(1)==1 && id(end)==numel(id));
    end
    
    % Check if unique identifiers
    if ~unique(id) % array is sorted so check adjacent differences
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
