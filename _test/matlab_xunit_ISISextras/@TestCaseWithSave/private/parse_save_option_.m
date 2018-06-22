function   [save_output,test_name,test_method_to_save] = ...
    parse_save_option_(name,name_default)
% Verify input to check if option '-save' has been provided
%

%
if ~ischarstring(name)
    error('TEST_CASE_WITH_SAVE:invalid_argument',...
        'The name of the test suite, if provided, has to be a char string');
end

if strncmpi(name,'-s',2)
    save_output=true;
else
    save_output=false;
end
name_parts = regexp(name,':','split');
if numel(name_parts) == 1
    test_method_to_save = [];
else
    test_method_to_save= name_parts{end};
end

if save_output
    test_name = name_default;
else
    test_name  = name;
end


