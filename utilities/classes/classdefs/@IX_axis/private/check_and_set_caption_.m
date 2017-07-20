function obj = check_and_set_caption_(obj,cap)
% Method verifies axis caption and sets axis caption if the value is valid
%
% Throws IX_axis:invalid_argument is caption is invalid
%
%
% $Revision: 536 $ ($Date: 2016-09-26 16:02:52 +0100 (Mon, 26 Sep 2016) $)
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

