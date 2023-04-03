function obj = set_raw_data(obj,pix)
%SET_RAW_DATA sets internal data array without comprehensive checks for 
% data integrity
%
if isempty(pix)
    obj.data_ = zeros(obj.DEFAULT_NUM_PIX_FIELDS,0);
    return
end

if ~isnumeric(pix) || size(pix,1) ~= obj.DEFAULT_NUM_PIX_FIELDS
    error('HORACE:PixelDataMemory:invalid_argument', ...
        'pixel data should be numeric array of [%d,npix] size.\n In fact, the class of input is %s and its size is: %s\n', ...
        obj.DEFAULT_NUM_PIX_FIELDS,class(pix),disp2str(size(pix)));
end
obj.data_ = pix;
%
% setting data remove misalignment 
if obj.is_misaligned_
    obj.alignment_matr_ = eye(3);
    obj.is_misaligned_  = false;
end