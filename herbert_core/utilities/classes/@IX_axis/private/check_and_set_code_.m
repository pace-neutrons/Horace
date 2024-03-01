function obj = check_and_set_code_(obj,code)
% Method verifies axis code and sets code if the value is valid
%
% Throws IX_axis:invalid_argument if the code is invalid
%

if isempty(code)
    obj.code_ = '';
    return
end
if is_string(code)
    obj.code_=code;
    return
end

error('HERBERT:IX_axis:invalid_argument', ...
    'Units code must be a character string. It is %s', ...
    class(code));


