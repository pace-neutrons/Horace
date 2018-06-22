function obj = check_and_set_methods2save_(obj,test_method_to_save,save_outputs)
% check if save ouptuts option is defined and set up the method to run and save
%
if ~save_outputs
    obj.test_method_to_save_ = {};
    return;
end

test_methods = getTestMethods(obj);

if isempty(test_method_to_save)
    obj.test_method_to_save_ = test_methods;
else
    idx = find(strcmpi(test_method_to_save,test_methods));
    if ~isempty(idx)
        obj.test_method_to_save_ = test_methods(idx);
    else
        error('TEST_CASE_WITH_SAVE:invalid_argument',...
            'Unrecognised test method to save: "%s"',test_method_to_save)
    end
end
