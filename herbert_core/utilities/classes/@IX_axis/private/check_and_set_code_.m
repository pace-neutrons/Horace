function obj = check_and_set_code_(obj,code)
% Method verifies axis code and sets code if the value is valid
%
% Throws IX_axis:invalid_argument if the code is invalid
%
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
%

if isempty(code)
    obj.code_ = '';
    return
end
if is_string(code)
    obj.code_=code;
    return
end

error('IX_axis:invalid_argument','Units code must be a character string');


