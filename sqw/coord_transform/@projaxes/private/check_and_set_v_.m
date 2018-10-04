function    obj = check_and_set_v_(obj,val)
% Verify and set v-parameters and set it to projaxis if verification
% successful

if isnumeric(val) && numel(val)==3 && norm(val)>obj.tol_
    if size(val,2) == 3
        obj.v_ = val;
    else
        obj.v_ = val';
    end
else
    error('PROJAXES:invalid_argument',...
        'v should be non-zero length numeric vector with 3 components')
end

