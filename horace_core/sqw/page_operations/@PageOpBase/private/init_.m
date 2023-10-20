function obj = init_(obj,in_obj)
% initialize page operation using parts of input sqw or
% PixelData object as the target for the operation.

obj.pix_data_range_ = PixelDataBase.EMPTY_RANGE;

%
if ~obj.inplace
    obj.write_handle_ = in_obj.get_write_handle(obj.outfile);
end

if isa(in_obj ,'PixelDataBase')
    obj.pix_             = in_obj;
    obj.img_             = [];
elseif isa(in_obj,'sqw')
    obj.img_             = in_obj.data;
    obj.pix_             = in_obj.pix;
    obj.npix             = obj.img_.npix;
    %
    obj.sig_acc_ = zeros(numel(obj.npix),1);
else
    error('HORACE:PageOpBase:invalid_argument', ...
        'Init method accepts PixelData or SQW object input only. Provided %s', ...
        class(in_obj))
end
% as we normally read data and immediately dump them back, what
% is the point of converting them to double and back?
% Keep precision.
obj.pix_.keep_precision = true;
obj.old_file_format_ = obj.pix_.old_file_format;
