function obj = check_and_set_w_(obj,val)
% Check w parameters and set them to projaxis if correct
%
isnum = isnumeric(val);
if  isnum &&numel(val)==3
    cand = val(:)';  % make it row vector
    is_small = abs(cand)<obj.tol_;
    if any(is_small)
        if all(is_small)
            error('HORACE:ortho_proj:invalid_argument',...
                'vector w can not be a 0-vector: [%g,%g,%g]',...
                cand(1),cand(2),cand(3))
        else
            cand(is_small) = 0;
        end
    end
    obj.w_ = cand;
elseif isempty(val)
    obj.w_ = [];
else
    error('HORACE:ortho_proj:invalid_argument',...
        'w should be non-zero length numeric 3-vector or empty value but it is: %s',...
        evalc('disp(val)'))
end
