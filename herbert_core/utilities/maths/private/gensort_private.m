function [B,ix] = gensort_private (A, public)
% Sorts an struct or object array
%
%   >> [B,ix] = gensort_private (A)             % default: public==true
%   >> [B,ix] = gensort_private (A, public)
%
% Input:
% ------
%   A       Struct or object array to be sorted (row or column vector)
%
%   public  Logical flag: (Default: true)
%            true:  Keep public properties (independent and dependent)
%                   More specifically, it calls an object method called 
%                  structPublic if it exists; otherwise it calls the
%                  generic function structPublic.
%            false: Keep independent properties only (hidden, protected and
%                   public)
%                   More specifically, it calls an object method called 
%                  structIndep if it exists; otherwise it calls the
%                  generic function structIndep.
%
% Output:
% -------
%   B       Structure array with all objects arrays resolved into structure
%           arrays
%
%   ix      Index array with the same size as A, so B = A(ix)
%
%
% Uses mergesort for O(n*log(n)) sorting time and for stable sorting, just
% like the intrinsic Matlab sort. However, it is inevitably slower being
% written in matlab code, and should only be used when the intrinsic sort
% cannot be used.

%--------------------------------------------------------------------------
% T.G.Perring 9 May 2019:
% Modified from mergesort written by Brian Moore (see details below)
% TGP added index array with the same behaviour as the instrinsic Matlab
% sort function
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
% Copyright (c) 2014, Brian Moore
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%--------------------------------------------------------------------------

if ~isvector(A)
    error('Only sorts vectors')
end

if nargin==1
    public = true;
end

% Case of empty input array (matches Matlab intrinsic sort)
if numel(A)==0
    B = A;
    ix = zeros(size(A));
    return
end

% Initialise for mergesort
B = A;
ix = (1:numel(A));
if iscolumn(A)
    ix = ix(:);     % ensures same shape as A
end

% Catch the case that all elements are the same
all_same = true;
for i=2:numel(A)
    if ~isequaln(A(i-1),A(i))
        all_same = false;
        break
    end
end
if all_same, return, end   % all elements are the same

% Catch the special case of a pre-sorted array
mono_increase = true;
for i=2:numel(A)
    if greater_than_private(A(i-1),A(i),public)
        mono_increase = false;
        break
    end
end
if mono_increase, return, end   % already sorted

% Knobs
kk = 15; % Insertion sort threshold, k >= 1

% Mergesort
n = length(B);
[B,ix] = mergesorti(B,ix,1,n,kk,public);

end

function [B,ix] = mergesorti(B,ix,ll,uu,kk,public)
% Sort x(ll:uu) via merge sort
% Note: In practice, x xhould be passed by reference

% Compute center index
mm = floor((ll + uu) / 2);

% Divide...
if ((mm + 1 - ll) <= kk)
    % Sort x(ll:mm) via insertion sort
    [B,ix] = insertionsorti(B,ix,ll,mm,public);
else
    % Sort x(ll:mm) via insertion sort
    [B,ix] = mergesorti(B,ix,ll,mm,kk,public);
end
if ((uu - mm) <= kk)
    % Sort x((mm + 1):uu) via insertion sort
    [B,ix] = insertionsorti(B,ix,mm + 1,uu,public);
else
    % Sort x((mm + 1):uu) via merge sort
    [B,ix] = mergesorti(B,ix,mm + 1,uu,kk,public);
end

% ... and conquer
% Combine sorted arrays x(ll:mm) and x((mm + 1):uu)
[B,ix] = merge(B,ix,ll,mm,uu,public);

end

function [B,ix] = insertionsorti(B,ix,ll,uu,public)
% Sort x(ll:uu) via insertion sort
% Note: In practice, x xhould be passed by reference

for j = (ll + 1):uu
    pivot = B(j);
    ix_pivot = ix(j);
    i = j;
    while ((i > ll) && greater_than_private(B(i - 1),pivot,public))
        B(i) = B(i - 1);
        ix(i) = ix(i - 1);
        i = i - 1;
    end
    B(i) = pivot;
    ix(i) = ix_pivot;
end

end

function [B,ix] = merge(B,ix,ll,mm,uu,public)
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
    if ~greater_than_private(L(i),B(j),public)
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
