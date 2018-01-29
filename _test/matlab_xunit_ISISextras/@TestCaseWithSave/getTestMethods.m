%--------------------------------------------------------------------------
function test_methods = getTestMethods(this)
% Find unit test methods (begin 'test' or 'Test', excluding the constructor)
class_name = class(this);
method_names = methods(this);
idx = cellfun(@(x)((~isempty(regexp(x,'^test','once')) ||...
    ~isempty(regexp(x,'^Test','once'))) &&...
    ~strcmpi(x,class_name)), method_names);
test_methods = method_names(idx);
end
