function assertEqualToTol(A, B, varargin)
% Assert that inputs are equal to within a tolerance
%   >> this = assertEqualToTol (A, B)
%   >> this = assertEqualToTol (A, B, 'key1', val1, 'key2', val2, ...)
%
% When a test suite is launched with runtests, then if the test fails
% a message is output to the screen.
%
% Input:
% ------
%   A, B        Values to be compared
%
%  'key1',val1  Optional keywords and associated values. These control
%              the tolerance and other parameters in the comparison.
%               Valid keywords are:
%                   'tol', 'reltol', abstol', 'ignore_str', 'nan_equal'
%               For full details of keywords that control the comparsion
%              see <a href="matlab:help('equal_to_tol');">equal_to_tol</a>
%              or class specific implementations of equal_to_tol, for example
%              see <a href="matlab:help('equal_to_tol');">equal_to_tol</a>
%



% Get names of input variables, if can    
name_a = variable_name(inputname(1), false, 1, 1, 'input_1');
name_b = variable_name(inputname(2), false, 1, 1, 'input_2');

% Perform comparison
[ok, message] = equal_to_tol (A, B,...
    'name_a', name_a, 'name_b', name_b, varargin{:});
if ~ok
    throwAsCaller(MException('assertEqualToTol:tolExceeded', ...
        '%s', message));
end
