function mex_Thrower(n,n_total,varargin)
% function, used in tests for generation of Matlab extensions with
% non-trivial MException.stack.
%
% generates exception after reaching n_total level of recursion.
%

% Inputs:
% n_total -- the depth of the recursion to throw exception from
% n       -- current depth of the recursion
% Optional:
% mexID   -- the string in the form AAA:bbb (double dot present within the stgint)
%            to use as thrown exception ID. if it is not ther, the thrown
%            exception id is 'TEST_EXCEPTION:reached'
%
% Results:
% Trown exeption on the level, defined by input n.

if ~exist('n_total', 'var')
    n_total = n;
end
if nargin>2
    mexID = varargin{1};
else
    mexID = 'TEST_EXCEPTION:reached';
end

if (n<=0)
    error(mexID,'Test exception at level %d',n_total+1)
else
    mex_Thrower(n-1,n_total,varargin{:});
end


