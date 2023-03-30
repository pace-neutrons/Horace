function  obj = set_alignment_mart_(obj,val)
%SET_ALIGNMENT_MATR_ helper property which checks and sets alignment matrix
%
if isempty(val)
    obj.alignment_mart_ = eye(3);
    obj.is_misaligned_ = false;
end
if ~isnumeric(val)
    error('HORACE:PixelDataBase:invalid_argument', ...
        'Alignment matrix must be 3x3 numeric matrix. Attempt to set class: %s', ...
        class(val));
end
if any(size(val) ~= [3,3])
    error('HORACE:PixelDataBase:invalid_argument', ...
        'Alignment matrix must be 3x3 matrix. Attempt to set the matrix of size: %s', ...
        mat2str(val))
end
%
difr = val - eye(3);
if max(abs(difr(:))) > 1.e-8
    obj.alignment_mart_ = val;
    obj.is_misaligned_ = true;
else
    obj.alignment_mart_ = eye(3);
    obj.is_misaligned_ = false;
end