function test_methods = getTestMethods_(this)
% Find methods that begin with 'test' or 'Test', excluding the constructor
%
%   >> test_methods = getTestMethods_(this)
%
% Input:
% ------
%   this            Class instance
%
% Output:
% -------
%   test_methods    Column vector cell array of method names that begin
%                   with 'test' or 'Test', excluding the class itself


class_name = class(this);
method_names = methods(this);
idx = cellfun(@(x)((~isempty(regexp(x,'^test','once')) ||...
    ~isempty(regexp(x,'^Test','once'))) &&...
    ~strcmpi(x,class_name)), method_names);
test_methods = method_names(idx);
