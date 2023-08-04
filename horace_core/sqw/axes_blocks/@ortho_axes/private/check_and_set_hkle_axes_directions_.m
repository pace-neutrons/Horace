function obj = check_and_set_hkle_axes_directions_(obj,val)
% setter for hkle_axes_direction matrix
if isempty(val)
    obj.hkle_axes_directions_ = [];
    return;
end
if ~isnumeric(val)
    error('HORACE:ortho_axes:invalid_argument', ...
        'hkle_axes_directions should be numeric 3x3 or 4x4 matrix. It is %s', ...
        disp2str(val));
end

if isequal(size(val),[3,3])
    val = [val,zeros(3,1);[0,0,0,1]];
end
if isequal(size(val),[4,4])
    if norm(val) < eps('single')
        error('HORACE:ortho_axes:invalid_argument', ...
            'The norm of hkle_axes_directions matrix can not be 0.\n Got matrix: %s', ...
            mat2str(val));

    end
    obj.hkle_axes_directions_ = val;
else
    error('HORACE:ortho_axes:invalid_argument', ...
        'hkle_axes_direction should be numeric 3x3 or 4x4 matrix. It is %s', ...
        disp2str(val));
end