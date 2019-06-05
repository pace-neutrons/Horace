function [B,ix] = mergesort(A)
%
% Needs <= and > defined for objects
%
%--------------------------------------------------------------------------
% Syntax:       sx = mergesort(x);
%
% Inputs:       x is a vector of length n
%
% Outputs:      sx is the sorted (ascending) version of x
%
% Description:  This function sorts the input array x in ascending order
%               using the mergesort algorithm
%
% Complexity:   O(n * log(n))    best-case performance
%               O(n * log(n))    average-case performance
%               O(n * log(n))    worst-case performance
%               O(n)             auxiliary space
%
% Author:       Brian Moore
%               brimoor@umich.edu
%
% Date:         January 5, 2014
%--------------------------------------------------------------------------

if ~isvector(A)
    error('Only sorts vectors')
end
B = A;
ix = (1:numel(A));
if iscolumn(A)
    ix = ix(:);     % ensures same shape as A
end

% Knobs
kk = 15; % Insertion sort threshold, k >= 1

% Mergesort
n = length(B);
[B,ix] = mergesorti(B,ix,1,n,kk);

end

function [B,ix] = mergesorti(B,ix,ll,uu,kk)
% Sort x(ll:uu) via merge sort
% Note: In practice, x xhould be passed by reference

% Compute center index
mm = floor((ll + uu) / 2);

% Divide...
if ((mm + 1 - ll) <= kk)
    % Sort x(ll:mm) via insertion sort
    [B,ix] = insertionsorti(B,ix,ll,mm);
else
    % Sort x(ll:mm) via insertion sort
    [B,ix] = mergesorti(B,ix,ll,mm,kk);
end
if ((uu - mm) <= kk)
    % Sort x((mm + 1):uu) via insertion sort
    [B,ix] = insertionsorti(B,ix,mm + 1,uu);
else
    % Sort x((mm + 1):uu) via merge sort
    [B,ix] = mergesorti(B,ix,mm + 1,uu,kk);
end

% ... and conquer
% Combine sorted arrays x(ll:mm) and x((mm + 1):uu)
[B,ix] = merge(B,ix,ll,mm,uu);

end

function [B,ix] = insertionsorti(B,ix,ll,uu)
% Sort x(ll:uu) via insertion sort
% Note: In practice, x xhould be passed by reference

for j = (ll + 1):uu
    pivot = B(j);
    ix_pivot = ix(j);
    i = j;
    while ((i > ll) && greater_than(B(i - 1),pivot))
        B(i) = B(i - 1);
        ix(i) = ix(i - 1);
        i = i - 1;
    end
    B(i) = pivot;
    ix(i) = ix_pivot;
end

end

function [B,ix] = merge(B,ix,ll,mm,uu)
% Combine sorted arrays x(ll:mm) and x((mm + 1):uu)
% Note: In practice, x xhould be passed by reference

% Note: In practice, use memcpy() or similar
L = B(ll:mm);
ix_L = ix(ll:mm);

% Combine sorted arrays
i = 1;
j = mm + 1;
k = ll;
while ((k < j) && (j <= uu))
    if ~greater_than(L(i),B(j))
        B(k) = L(i);
        ix(k) = ix_L(i);
        i = i + 1;
    else
        B(k) = B(j);
        ix(k) = ix(j);
        j = j + 1;
    end
    k = k + 1;
end

% Note: In practice, use memcpy() or similar
B(k:(j - 1)) = L(i:(i + j - k - 1));
ix(k:(j - 1)) = ix_L(i:(i + j - k - 1));

end
