function  obj = set_alignment_matr_(obj,val,pix_agerage_proc_function)
%SET_ALIGNMENT_MATR_ helper property which checks and sets alignment matrix
% to the PixelData class.
%
% The alignment matrix intended for transforming current pixel
% Q-coordinates into Crystal Cartesian coordinate system if existing
% coordinate pixel coordinate system differs from Crystal Cartesian due to
% erroneous alignment.
%
was_misaligned = obj.is_misaligned;
prev_matr      = obj.alignment_matr_;
if isempty(val)
    obj.alignment_matr_ = eye(3);
    obj.is_misaligned_ = false;
    if was_misaligned
        obj = pix_agerage_proc_function(obj,'q_coordinates');
    end
    return;
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
difr = val - prev_matr;
if max(abs(difr(:))) > 1.e-8
     obj.alignment_matr_ = val;
     obj.is_misaligned_ = true;
     obj = pix_agerage_proc_function(obj,'q_coordinates');
end