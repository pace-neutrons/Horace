function  obj = put_pix_metadata(obj,pix_class)
%PUT_PIX_METADATA store pixel metadata containing in pix_class using fully
% instance of file-accessor
if ~(isa(pix_class,'PixelDataBase') || isa(pix_class,'pix_metadata') || isa(pix_class,'sqw'))
    error('HORACE:faccess_sqw_v4:invalid_argument',...
        'This method accepts only class, containing PixelData or pix_metadata as input. In fact input class is: %s',...
        class(pix_class));
end
obj = obj.put_sqw_block('bl_pix_metadata',pix_class);
