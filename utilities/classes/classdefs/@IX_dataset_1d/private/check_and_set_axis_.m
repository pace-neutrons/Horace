function obj = check_and_set_axis_(obj,fld_name,val)
% function checks  appropriate axis to be valid and sets valid axis
%
% Throws IX_dataset_1d:invalid _rgument if axis is not acceptable

if ischar(val)||iscellstr(val)
    obj.([fld_name,'_'])=IX_axis(val);
    return
end
if isa(val,'IX_axis')
    obj.([fld_name,'_'])= val;
    return;
end
if isnumeric(val)
    obj.([fld_name,'_'])= IX_axis(num2str(val));
    return
end
error('IX_dataset_1d:invalid_argument',...
    [fld_name,' annotation must be character array or IX_axis object (type help IX_axis)']);

