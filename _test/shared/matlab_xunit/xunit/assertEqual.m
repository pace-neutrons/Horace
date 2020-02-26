function assertEqual(A, B, custom_message,tol)
%assertEqual Assert that inputs are equal
%   assertEqual(A, B) throws an exception if A and B are not equal.  A and B
%   must have the same class and sparsity to be considered equal.
%
%   assertEqual(A, B, MESSAGE) prepends the string MESSAGE to the assertion
%   message if A and B are not equal.
%
%   Examples
%   --------
%   % This call returns silently.
%   assertEqual([1 NaN 2], [1 NaN 2]);
%
%   % This call throws an error.
%   assertEqual({'A', 'B', 'C'}, {'A', 'foo', 'C'});
%
%   See also assertElementsAlmostEqual, assertVectorsAlmostEqual
%  If present tol:
%   tol     Tolerance criterion for numeric arrays (Default: [0,0] i.e. equality)
%           It has the form: [abs_tol, rel_tol] where
%               abs_tol     absolute tolerance (>=0; if =0 equality required)
%               rel_tol     relative tolerance (>=0; if =0 equality required)
%           If either criterion is satisfied then equality within tolerance
%           is accepted.
%             Examples:
%               [1e-4, 1e-6]    absolute 1e-4 or relative 1e-6 required
%               [1e-4, 0]       absolute 1e-4 required
%               [0, 1e-6]       relative 1e-6 required
%               [0, 0]          equality required
%               0               equivalent to [0,0]
%
%            A scalar tolerance can be given where the sign determines if
%           the tolerance is absolute or relative:
%               +ve : absolute tolerance  abserr = abs(a-b)
%               -ve : relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%             Examples:
%               1e-4            absolute tolerance, equivalent to [1e-4, 0]
%               -1e-6           relative tolerance, equivalent to [0, 1e-6]
%


%   Steven L. Eddins
%   Copyright 2008-2010 The MathWorks, Inc.

if nargin < 3
    custom_message = '';
end
if nargin < 4
    tol = [0,0];
end

if ~ (issparse(A) == issparse(B))
    message = xunit.utils.comparisonMessage(custom_message, ...
        'One input is sparse and the other is not.', A, B);
    throwAsCaller(MException('assertEqual:sparsityNotEqual', '%s', message));
end

if ~strcmp(class(A), class(B))
    message = xunit.utils.comparisonMessage(custom_message, ...
        'The inputs differ in class.', A, B);
    throwAsCaller(MException('assertEqual:classNotEqual', '%s', message));
end

[ok,mess] = equal_to_tol(A,B,tol);
if ~ok
    if verLessThan('Matlab','R2016a')        
        nl = sprintf('\n');
    else
        nl = newline;
    end
    message = xunit.utils.comparisonMessage(custom_message, ...
        'Inputs are not equal.', A, B);
    message = [message,nl,mess];
    throwAsCaller(MException('assertEqual:nonEqual', '%s', message));
end

