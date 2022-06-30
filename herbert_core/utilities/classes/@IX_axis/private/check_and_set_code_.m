function obj = check_and_set_code_(obj,code)
% Method verifies axis code and sets code if the value is valid
%
% Throws IX_axis:invalid_argument if the code is invalid
%
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
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


