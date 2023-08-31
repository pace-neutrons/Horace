function obj = init_from_file_accessor_(obj, faccessor,update,norange)
% Initialise a PixelDataFileBased object from a file accessor

if ~faccessor.sqw_type
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
        'f_accessor for file: %s is not a sqw-file accessor', faccessor.full_filename);
end

obj.offset_   = faccessor.pix_position;
obj.page_num_ = 1;
obj.num_pixels_ = double(faccessor.npixels);
tail = faccessor.eof_position-faccessor.pixel_data_end;
obj.f_accessor_ = []; % necessary as otherwise it may use the
% previous instance of file_accessor and become invalid
obj.f_accessor_ = memmapfile(faccessor.full_filename, ...
    'Format', obj.get_memmap_format(tail), ...
    'Repeat', 1, ...
    'Writable', update, ...
    'Offset', obj.offset_);

meta = faccessor.get_pix_metadata();
% Metadata filename may differ from current filename; update filename here
obj.metadata = meta;

if norange
    return;
end

if ~obj.is_range_valid()
    warning('HORACE:old_file_format', ...
            ['\n', ...
             '*** SQW file does not contain pixel data averages.\n', ...
             '*** This may be because is is an old-format file or realigned file.\n', ...
             '*** Averages will be calculated when needed which may take substantial time for large files\n', ...
             '*** Upgrade your saved sqw object to not have to recalculate these each time you load this file\n', ...
             '*** To upgrade this file run\n>> upgrade_file_format(''%s'')'], ...
        obj.full_filename);
end

end
