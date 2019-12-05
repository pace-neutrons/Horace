function [C, ix, nelmts, nbeg, nend] = unique_extra (A)
% Find unique values of an array and the indices in the original array
%
%   >> [C, ix, nelmts, nbeg, nend] = unique_extra (A)
%
% Input:
% ------
%   A       Array (of any class accepted by Matlab intrinsic sort function)
%
% Output:
% -------
%   C       Unique elements of A in ascending order
%           If A is a row vector, then C is a row vector
%           Otherwise C is a column vector
%
%   ix      Array such that ix(nbeg(i):nend(i)) are the elements of A that
%           are equal to C(i) i.e. A(ix(nbeg(i):nend(i))) = C(i)
%           the indices ix preserve the order of equal elements in A, so
%           that diff(ix(nbeg(i):nend(i)))>=0
%           Column vector
%
%   nelmts  The number of occurences of the values of C
%           Column vector
%
%   nbeg    Indices into ix of the start of each range of indices
%           corresponding to unique values of A
%           Column vector
%
%   nbeg    Indices into ix of the end of each range of indices
%           corresponding to unique values of A
%           Column vector


% Original author: T.G.Perring  2019-03-25
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


% NOTE: If want to add the functionality of Matlab intrinsic unique, need
%       to return ia and ic. Uncomment the corresponding lines below. The 
%       calculation of ic will be as long as the rest of the calculation.
%
% Have not been able to think of a fast way to do this using unique, which
% can deal with a larger set of options. The problem is using C, ia, ic to
% generate ix. Can get nelmts using accumarray on ic, and nbeg=ic(ia) (and
% then nend=nbeg+nelmts-1).
%
% This routine is faster than unique in the case of an already sorted array


% Trivial case of empty input array
if isempty(A)
    if isrowvector(A)
        C = A;
    else
        C = A(:);
    end
%     ia = zeros(0,1);
%     ic = zeros(0,1);
    ix = zeros(0,1);
    nelmts = zeros(0,1);
    nbeg = zeros(0,1);
    nend = zeros(0,1);
    return
end

% Non-empty array
if issorted(A(:))
    % Ascending sorted (or all equal)
    if isequal(A(1),A(end))
        C = A(1);
%         ia = 1;
%         ic = ones(numel(A),1);
        ix = (1:numel(A))';
        nelmts = numel(A);
        nbeg = 1;
        nend = numel(A);
        return
    else
        B = A(:);
        ix = (1:numel(A))';
    end
else
    % Needs sorting.
    % Note that we do not deal with the case of a descending sorted array A
    % as a special case because there is no quick way to ensure that ix 
    % preserved the order of equal entries in A. The obvious lines
    %       B = flipud(A(:));
    %       ix = numel(A):-1:1;
    % result in ix having *reversed* the order of equal elements
    [B,ix] = sort(A(:));
end

nend = [find(diff(B));numel(B)];
nbeg = 1+[0;nend(1:end-1)];
nelmts = nend-nbeg+1;
C = B(nbeg);
if isrowvector(A)
    C = C';     % make row vector to match behaviour of unique
end

% ia = ix(nbeg);  % first occurences in A
% ic(ix) = replicate_iarray(1:numel(nelmts),nelmts);
% ic = ic(:);     % for some mysterious reason ic is a row even though ix and replicate_iarray are not

