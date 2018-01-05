function assertEqualToTol(A, B, varargin)
% Assert that inputs are equal to within a tolerance
%   >> this = assertEqualToTol (A, B)
%   >> this = assertEqualToTol (A, B, 'key1', val1, 'key2', val2, ...)
%   >> this = assertEqualToTol (..., message)
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
%   message     Optional string to prepend to the assertion output message


% Parse the input arguments
if rem(nargin,2)==1
    if is_string(varargin{end})
        args=varargin(1:end-1);
        message = varargin{end};
    else
        error('Check number of arguments')
    end
else
    args=varargin;
    message = '';
end

% Perform comparison
[ok, mess] = equal_to_tol (A, B,...
    'name_a', inputname(1), 'name_b', inputname(2), args{:});
if ~ok
    if ~isempty(message)
        message = [message,newline,mess];
    else
        message = mess;
    end
    throwAsCaller(MException('assertEqualToTol:tolExceeded', ...
        '%s', message));
end
