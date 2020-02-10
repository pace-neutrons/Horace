function mex_Thrower(n,n_total)
% function, used in tests for generation of Matlab extensions with
% non-trivial MException.stack.
%
% generates exception after reaching n_total level of recursion.
%

% Inputs:
% n_total -- the depth of the recursion to throw exception from
% n       -- current depth of the recursion
%
% Results:

if ~exist('n_total','var')
    n_total = n;
end

if (n<=0)
    error('TEST_EXCEPTION:reached','Test exception at level %d',n_total+1)
else
    mex_Thrower(n-1,n_total);
end


