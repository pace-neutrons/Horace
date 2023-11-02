function obj = check_and_set_caption_(obj,cap)
% Method verifies axis caption and sets axis caption if the value is valid
%
% Throws HERBERT:IX_axis:invalid_argument is caption is invalid
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

error('HERBERT:IX_axis:invalid_argument', ...
    'Caption must be character or cell array of strings. It is %s', ...
    class(cap));


