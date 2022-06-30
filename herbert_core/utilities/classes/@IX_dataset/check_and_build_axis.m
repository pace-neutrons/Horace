function val = check_and_build_axis(val)
% function checks  appropriate axis to be valid and build valid axis
%
% Throws IX_dataset_1d:invalid _rgument if axis is not acceptable
if isa(val,'IX_axis')
    return;
end

if ischar(val)||iscellstr(val)
    val =IX_axis(val);
    return
end

if isnumeric(val)
    val = IX_axis(num2str(val));
    return
end
error('IX_dataset:invalid_argument',...
    'Axis annotation must be character array or IX_axis object (type help IX_axis)');

