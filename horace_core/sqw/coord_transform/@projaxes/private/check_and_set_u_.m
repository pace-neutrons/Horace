function obj = check_and_set_u_(obj,val)
% Verify and set u-parameters and set it to projaxis if verification
% successful

if isnumeric(val) && numel(val)==3 && norm(val)>obj.tol_
    if size(val,2) == 3
        obj.u_ = val;
    else
        obj.u_ = val';
    end
else
    error('PROJAXES:invalid_argument',...
        'u should be non-zero length numeric vector with 3 components')
end

