function assertEqual(A, B, custom_message,tol,varargin)
%assertEqual Assert that inputs are equal
%   assertEqual(A, B) throws an exception if A and B are not equal.  A and B
%   must have the same class and sparsity to be considered equal.
%
%   assertEqual(A, B, MESSAGE) prepends the string MESSAGE to the assertion
%   message if A and B are not equal.
%
% Inputs:
% A      -- one object to compare
% B      -- another object to compare
% Optional:
% custom message  -- if provided, exception would contan the message
%                    provided here. Message can not start with '-' symbol
%                    or be equal to any key accepted by equal_to_tol
%                    function.
% tol             -- tolerance. See below for details.
% varargin        -- any list of additional keys starting with '-' or
%                    key-value pairs equal_to_toll would accept.
%
%   Examples
%   --------
%   % This call returns silently.
%   assertEqual([1 NaN 2], [1 NaN 2],'-nan_equal');
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
%
% MODIFIED FOR HORACE
% 12-2024

if nargin < 3
    custom_message = '';
    argi = varargin;
elseif istext(custom_message)
    if startsWith(custom_message,'-')
        % key in the form '-key' is provided
        argi =[custom_message;varargin(:)];
        custom_message = '';
    else
        % retrieve list of keys, accepted by equal_to_tol;
        [~,~,~,opt] = process_inputs_for_eq_to_tol('','','','',false);
        keys = fieldnames(opt);
        if ismember(custom_message,keys)
            argi =[custom_message;tol;varargin(:)];
            custom_message = '';
        else
            argi = varargin;
        end
    end
end

name_a = variable_name(inputname(1), false, 1, 1, 'input_1');
name_b = variable_name(inputname(2), false, 1, 1, 'input_2');
if nargin < 4
    argi = ['tol';[0,0];'name_a';name_a;'name_b';name_b;argi(:)];
else
    argi = ['tol';tol;argi(:)];
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
if strncmp(class(A),'matlab.',7) % comparing user interface (persumably figures)
    ok = isequal(A,B);
    if ~ok
        throwAsCaller(MException('assertEqual:classNotEqual', ...
            'Internal classes %s are different according to isequal',class(A)));        
    end
    return;
end

[ok,mess] = equal_to_tol(A,B,argi{:});
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

