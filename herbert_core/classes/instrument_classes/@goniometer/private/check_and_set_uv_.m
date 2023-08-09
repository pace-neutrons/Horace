function obj = check_and_set_uv_(obj,name,val)
% Verify and set u-v parameters and set it if verification is
% successful

if isnumeric(val)
    if numel(val)==3
        cand = val(:)'; % make it row vector
    elseif numel(val) == 1
        cand = [val,val,val];
    else
        error('HERBERT:goniometer:invalid_argument',...
            '%s should be non-zero length numeric vector with 3 components. Actually it is %s',...
            name,evalc('disp(val)'))
    end

    is_small = abs(cand)<obj.tol_;
    if any(is_small)
        if all(is_small)
            error('HERBERT:goniometer:invalid_argument',...
                'vector %s can not be a 0-vector: [%g,%g,%g]',...
                name,cand(1),cand(2),cand(3))
        else
            cand(is_small) = 0;
        end
    end
    obj.([name,'_']) = cand;
else
    error('HERBERT:goniometer:invalid_argument',...
        '%s should be non-zero length numeric vector . Actually it is %s',...
        name,evalc('disp(val)'))
end
%
if obj.do_check_combo_arg_
    obj = check_combo_arg(obj);
end

