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


in_name = cell(1,2);
in_name{1} = inputname(1);
in_name{2} = inputname(2);

if nargin>2
    opt = {'name_a','name_b'};
    [keyval_list,other]=extract_keyvalues(varargin,opt);
    if ~isempty(keyval_list)
        ic = 1;
        for i=1:2:numel(keyval_list)-1
            in_name{ic} = keyval_list{i+1};
            ic = ic+1;
        end
    end
else
    other = {};
end
% Perform comparison
[ok, message] = equal_to_tol (A, B,...
    'name_a', in_name{1}, 'name_b', in_name{2}, other{:});
if ~ok
    throwAsCaller(MException('assertEqualToTol:tolExceeded', ...
        '%s', message));
end
