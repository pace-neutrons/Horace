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
obj.f_accessor_ = []; % this one necessary as otherwise it may use the
% previous instance of file_acessors, and it may become ivalid
obj.f_accessor_ = memmapfile(faccessor.full_filename, ...
    'Format', obj.get_memmap_format(tail), ...
    'Repeat', 1, ...
    'Writable', update, ...
    'Offset', obj.offset_);

meta = faccessor.get_pix_metadata();
% I believe, metadata filename may differ from current filename, so better to have recent filename
% here
obj.metadata = meta;

if norange
    return;
end

if ~obj.is_range_valid()
    warning('HORACE:old_file_format',[...
        '\n*** SQW file: %s\n    does not contain pixel data averages.\n', ...
        '*** It is either old format binary sqw file or realigned sqw file\n',...
        '*** For such files averages are calculating on request which may take substantial time for filebacked sqw objects\n',...
        '*** Update file format of your sqw objects not to recalculate these averages each time the averages are requested\n' ...
        '*** Run upgrade_file_format(filename) from horace_core/admin folder to do that'],...
        obj.full_filename);
end
