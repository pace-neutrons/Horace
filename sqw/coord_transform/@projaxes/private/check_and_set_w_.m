function obj = check_and_set_w_(obj,val)
% Check w parameters and set them to projaxis if correct
%
isnum = isnumeric(val);
if  isnum &&numel(val)==3
    if size(val,2) == 3
        obj.w_ = val;
    else
        obj.w_ = val';
    end
elseif isempty(val) || (isnum && norm(val)<obj.tol_)
    obj.w_ = [];
else
    error('PROJAXEX:invalid_argument',...
        'w should be non-zero length numeric 3-vector or emtpy value')
end

