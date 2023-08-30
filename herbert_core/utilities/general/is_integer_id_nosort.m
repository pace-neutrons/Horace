function [ok,mess,ix] = is_integer_id_nosort(id_in)
% Check that identifiers are unique, and return indexing array
%
%   >> [ok,mess,ix,perm] = is_integer_id(id)
%
% Input:
% ------
%   id_in   Input index array
%
% Output:
% -------
%   ok      True if indicies are unique, false if not
%   mess    Message if not OK; empty string if ok
%   ix      Indexing array (column vector)
%           Kept for interchangeability with the sort version
%           but now have ix = [] always

% columnize
id = id_in(:);

% empty id_in will crash the all(id>=1) below
if isempty(id)
    ok = false;
    mess = 'id array must not be empty';
    ix = [];
    return;
end

ok = true;
mess = '';

% Check inputs are positive integers
if all(id>0) && all(rem(id,1)==0)
    % no sorting in this version of the function
    % so just construct the no-perm versions of ix and perm
    ix = [];
        
    % Check if unique identifiers; here use unique as we are not doing any
    % other sorting
    if ~unique(id) 
        ok = false;
        mess = 'identifiers must be unique';
        ix = [];
    end
else
    ok = false;
    mess = 'identifiers must have integer values and be greater than zero';
    ix = [];
end
