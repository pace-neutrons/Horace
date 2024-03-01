function obj=check_and_set_title_(obj,val)
% check if title is acceptable and set it
%
% Throws HERBERT:IX_dataset_1d:invalid_argument if the titile is invalid
%
if isempty(val)
    obj.title_ = {};
elseif istext(val)
    obj.title_=cellstr(val);
elseif iscellstr(val)
    obj.title_ = val(:);
elseif isnumeric(val)
    obj.title_ = num2str(val);
else
    error('HERBERT:IX_dataset_1d:invalid_argument',...
        'Title must be character array or cell array of strings or numeric value')
end
%
