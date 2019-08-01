function obj=check_and_set_title_(obj,val)
% check if title is acceptable and set it
%
% Throws IX_dataset_1d:invalid_argument if the titile is invalid
%

if ischar(val)||iscellstr(val)
    if ischar(val)
        obj.title_=cellstr(val);
    else
        obj.title_ = val(:);
    end
elseif isnumeric(val)
    obj.title_ = num2str(val);
else
    error('IX_dataset_1d:invalid_argument',...
        'Title must be character array or cell array of strings or numeric value')
end
%


