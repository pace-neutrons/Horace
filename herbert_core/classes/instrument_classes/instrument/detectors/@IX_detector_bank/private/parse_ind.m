function [sz, ix, iarr, ind] = parse_ind (nel, varargin)
% Check that the detector indices and wavevectors are consistently sized arrays
%
%   >> [sz, ix, iarr, ind] = parse_ind (nel)
%
%   >> [sz, ix, iarr, ind, argout] = parse_ind (nel, ind_in)
%
%
% Input:
% ------
%   nel         The number of elements in each array
%
%   ind_in      Global indices list. Scalar or array.
%               Default: all indicies in increasing order (ie ind=1:sum(nel(:)))
%
% It is assumesd that the input arguments are consistent
%
%
% Output:
% -------
%   sz          Size of ind (below) - used to reshape output.
%
%   ix          Column vector of indices that give the positions into ind_in
%              of the reordered values in iarr and ind (below)
%
%   iarr        Column vector of array indices from which there is at
%              least one element selected by the global indices list.
%               iarr is sorted into increasing order
%
%   ind         If elements come from a single array (i.e. iarr is scalar)
%              then ind is a column vector of local indicies in that array.
%               If elements came from two or more arrays, (i.e. a vector)
%              then ind is a column cell array of column vectors of local
%              indices into the arrays in the order originally given by iarr.


ixend = cumsum(nel(:));
ixbeg = ixend - nel(:) + 1;
ind2arr = replicate_iarray(1:numel(nel), nel);

% Check ind and wvec
if numel(varargin)==0
    ind_in = 1:ixend(end);  % all indicies
    
elseif numel(varargin)==1
    if ~isempty(varargin{1})
        ind_in = varargin{1};
    else
        throwAsCaller(MException('parse_ind:invalid_arguments',...
            '''ind'' cannot not be empty'));
    end
    
else
    throwAsCaller(MException('parse_ind:invalid_arguments',...
        'Check the number of input arguments'))
end
sz = size(ind_in);

% Convert the indices into array and local indices (and as column vectors)
[iarr, ix, ~, nbeg, nend] = unique_extra (ind2arr(ind_in(:)));
iarr = iarr(:);
if numel(iarr)==1
    ind = ind_in(:) - ixbeg(iarr) + 1;
else
    ind = arrayfun(@(ilo,ihi,ioffset)(ind_in(ix(ilo:ihi))-ioffset+1), nbeg, nend,...
        ixbeg(iarr), 'uniformOutput', false);
    for i=1:numel(ind)
        ind{i} = ind{i}(:);
    end
end
