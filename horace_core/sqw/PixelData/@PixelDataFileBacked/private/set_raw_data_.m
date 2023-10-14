function obj = set_raw_data_(obj, pix)
%SET_RAW_DATA_ set internal data array without comprehensive checks for
% data integrity and data ranges.
%
% May invalidate object integrity, so further operations are necessary
%

if size(pix,1) ~= PixelDataBase.DEFAULT_NUM_PIX_FIELDS
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'PixelDataFileBacked requires %d columns of input data. Your data has %d columns',...
        PixelDataBase.DEFAULT_NUM_PIX_FIELDS, size(init,1));
end
if ~isempty(obj.f_accessor_)
    obj.f_accessor_.Data.data(:,1:size(pix,2)) = pix;
else
    tmp_file = PixelDataBase.build_op_filename(obj.full_filename,'');
    write_h  = pix_write_handle(tmp_file);
    write_h.save_data(pix);
    init_info = write_h.release_pixinit_info();
    obj = obj.init(init_info);
    % delete results as pixels go out of scope
    if write_h.is_tmp_file
        obj.tmp_file_holder_ = TmpFileHandler(write_h.tmp_file_name,true);
    end
    % call delete explicitly not to wait until it is deleted by memory manager
    write_h.delete();
end