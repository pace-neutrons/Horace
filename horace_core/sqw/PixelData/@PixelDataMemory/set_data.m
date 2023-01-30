function obj = set_data(obj,pix)
%SET_DATA set internal data without comprehensive checks for data integrity
%
if isempty(pix)
    obj.data_ = zeros(obj.DEFAULT_NUM_PIX_FIELDS,0);
    return
end

if ~isnumeric(pix) || size(pix,1) ~= obj.DEFAULT_NUM_PIX_FIELDS
    error('HORACE:PixelDataMemory:invalid_argument', ...
        'pixel data should be numeric array of [%d,npix] size. In fact, the class of input is %s and its size: %s', ...
        obj.DEFAULT_NUM_PIX_FIELDS,class(pix),disp2str(size(pix)));
end
obj.data_ = pix;