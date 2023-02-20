function obj = set_raw_data_(obj, pix)
%SET_RAW_DATA_ set internal data array without comprehensive checks for data integrity
%

obj.f_accessor_ = [];
file_name = obj.full_filename;

if size(pix,1) ~= PixelDataBase.DEFAULT_NUM_PIX_FIELDS
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
          'PixelDataFileBacked requires %d columns of input data. Your data has %d columns',...
          PixelDataBase.DEFAULT_NUM_PIX_FIELDS, size(init,1));
end

obj.offset_       = 0;
obj.num_pixels_   = size(pix,2);
obj.data_range    = [min(pix,[],2),max(pix,[],2)]';

fh = fopen(file_name,'wb+');
if fh<1
    error('HORACE:PixelDataFileBacked:runtime_error', ...
          'Can not open data file %s for file-backed pixels',...
          file_name);
end

fwrite(fh, single(pix), 'single');
fclose(fh);

obj.f_accessor_   = memmapfile(obj.full_filename, ...
                               'format', {'single',[PixelDataBase.DEFAULT_NUM_PIX_FIELDS,obj.num_pixels_],'data'}, ...
                               'Repeat', 1, ...
                               'Writable', true, ...
                               'offset', obj.offset_);

end
