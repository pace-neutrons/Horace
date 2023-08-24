function obj = set_raw_data_(obj, pix)
%SET_RAW_DATA_ set internal data array without comprehensive checks for data integrity
%

if size(pix,1) ~= PixelDataBase.DEFAULT_NUM_PIX_FIELDS
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
          'PixelDataFileBacked requires %d columns of input data. Your data has %d columns',...
          PixelDataBase.DEFAULT_NUM_PIX_FIELDS, size(init,1));
end

obj.num_pixels_   = size(pix,2);

obj = obj.get_new_handle();
obj.format_dump_data(pix);
obj = obj.finish_dump();

obj = obj.recalc_data_range('all');


