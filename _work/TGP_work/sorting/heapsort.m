function B = heapsort(A)
%--------------------------------------------------------------------------
% Syntax:       sx = heapsort(x);
%               
% Inputs:       x is a vector of length n
%               
% Outputs:      sx is the sorted (ascending) version of x
%               
% Description:  This function sorts the input array x in ascending order
%               using the heapsort algorithm
%               
% Complexity:   O(n * log(n))    best-case performance
%               O(n * log(n))    average-case performance
%               O(n * log(n))    worst-case performance
%               O(1)             auxiliary space
%               
% Author:       Brian Moore
%               brimoor@umich.edu
%               
% Date:         January 5, 2014
%--------------------------------------------------------------------------
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
    error('Array to be sorted must be a row or column vector')
end

% Copy for output
B = A;
ix = 1:numel(A);

% Build max-heap from x
n = length(B);
B = buildmaxheap(B,n);

% Heapsort
heapsize = n;
for i = n:-1:2
    % Put (n + 1 - i)th largest element in place
    B = swap(B,1,i);
    
    % Max-heapify x(1:heapsize)
    heapsize = heapsize - 1;
    B = maxheapify(B,1,heapsize);
end

end

function x = buildmaxheap(x,n)
% Build max-heap out of x
% Note: In practice, x xhould be passed by reference

for i = floor(n / 2):-1:1
    % Put children of x(i) in max-heap order
    x = maxheapify(x,i,n);
end

end

function x = maxheapify(x,i,heapsize)
% Put children of x(i) in max-heap order
% Note: In practice, x xhould be passed by reference

% Compute left/right children indices
ll = 2 * i; % Note: In practice, use left bit shift
rr = ll + 1; % Note: In practice, use left bit shift, then add 1 to LSB

% Max-heapify
if ((ll <= heapsize) && (x(ll) > x(i)))
    largest = ll;
else
    largest = i;
end
if ((rr <= heapsize) && (x(rr) > x(largest)))
    largest = rr;
end
if (largest ~= i)
    x = swap(x,i,largest);
    x = maxheapify(x,largest,heapsize);
end

end

function [x, ix] = swap(x, ix, i,j)
% Swap x(i) and x(j)
% Note: In practice, x xhould be passed by reference

val = x(i);
x(i) = x(j);
x(j) = val;

ind = ix(i);
ix(i) = ix(j);
ix(j) = ind;

end
