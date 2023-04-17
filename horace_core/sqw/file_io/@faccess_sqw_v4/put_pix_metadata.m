function  obj = put_pix_metadata(obj,pix_class)
%PUT_PIX_METADATA store pixel metadata containing in pix_class using fully
% instance of file-accessor
if ~isa(pix_class,'PixelDataBase')
    error('HORACE:faccess_sqw_v4:invalid_argument',...
        'This method accepts instance of PixelDataBase as input. In fact you provided class %s',...
        class(pix_class));
end
obj = obj.put_sqw_block('bl_pix_metadata',pix_class);

end
