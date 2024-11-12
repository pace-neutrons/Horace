function  [obj,alignment_changed] = set_alignment_matr_(obj,val,pix_proc_function)
%SET_ALIGNMENT_MATR_ helper property which checks and sets alignment matrix
% to the PixelData class.
%
% The alignment matrix intended for transforming current pixel
% Q-coordinates into Crystal Cartesian coordinate system if existing
% coordinate pixel coordinate system differs from Crystal Cartesian due to
% erroneous alignment.
%
% Inputs:
% val   -- 3x3 rotation matrix used in alignment
% pix_proc_function
%       -- the function which should be applied to PixelDataBase class when
%          alignment changed
%
% Returns
% obj   -- PixelDataBase object modified accounting for alignment matrix.
% alignment_changed
%       -- true if alignment have changed and false otherwise.
%
prev_matr      = obj.alignment_matr_;
if isempty(val)
    difr = eye(3) - prev_matr;
    if max(abs(difr(:))) > 1.e-8
        alignment_changed = true;
    else
        alignment_changed = false;
    end
    obj.alignment_matr_ = eye(3);
    obj.is_corrected_   = false;
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
    alignment_changed   = true;
    obj.alignment_matr_ = val;
    mal_value = val-eye(3);
    if any(abs(mal_value(:))>eps('single'))
        obj.is_corrected_  = true;
    else
        obj.is_corrected_  = false;
    end
    obj = pix_proc_function(obj,'q_coordinates');
else
    alignment_changed = false;
end
