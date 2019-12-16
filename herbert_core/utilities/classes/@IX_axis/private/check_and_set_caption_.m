function obj = check_and_set_caption_(obj,cap)
% Method verifies axis caption and sets axis caption if the value is valid
%
% Throws IX_axis:invalid_argument is caption is invalid
%
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
%

if isempty(cap)
    obj.caption_ = {};
    return
end
if ischar(cap) && numel(size(cap))==2
    obj.caption_=cellstr(cap);
    return
end
if iscellstr(cap)
    obj.caption_=cap(:);
    return
end

error('IX_axis:invalid_argument','Caption must be character or cell array of strings');


