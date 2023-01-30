function obj = init_from_file_accessor_(obj, faccessor,update)
% Initialise a PixelData object from a file accessor
if ~faccessor.sqw_type
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'f_accessor for file: %s is not sqw-file accessor',faccessor.full_filename);
end
obj.full_filename = faccessor.full_filename;
obj.offset_       = faccessor.pix_position;
obj.page_num_  = 1;
obj.num_pixels_ = double(faccessor.npixels);
obj.data_range_ = faccessor.get_data_range();
obj.f_accessor_ = memmapfile(obj.full_filename,'format', ...
    {'single',double([9,faccessor.npixels]),'data'}, ...
    'writable', update, 'offset', obj.offset_);

obj.data_range_ = faccessor.get_data_range();
undefined = obj.data_range == PixelDataBase.EMPTY_RANGE;
if any(undefined(:))
    warning('HORACE:old_file_format',....
        'SQW file: %s contains data in old binary format not containing pixel data averages.\n Update file format not to recalculate these averages each time the sqw file is used\n',...
        obj.full_filename);
    obj = obj.reset_changed_coord_range('all');
end
