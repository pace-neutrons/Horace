function obj = init_from_file_accessor_(obj, faccessor,update,norange)
% Initialise a PixelDataFileBases object from a file accessor

if ~faccessor.sqw_type
    error('HORACE:PixelDataFileBacked:invalid_argument', ...
          'f_accessor for file: %s is not sqw-file accessor', faccessor.full_filename);
end

obj.full_filename = faccessor.full_filename;
obj.offset_ = faccessor.pix_position;
obj.page_num_ = 1;
obj.num_pixels_ = double(faccessor.npixels);
obj.f_accessor_ = memmapfile(obj.full_filename, ...
                             'Format', obj.get_memmap_format(), ...
                             'Repeat', 1, ...
                             'Writable', update, ...
                             'Offset', obj.offset_);

fac_range  = faccessor.get_data_range();
undefined = fac_range == PixelDataBase.EMPTY_RANGE;

if ~any(undefined(:))
    obj.data_range_ = fac_range;
end

if norange
    return;
end

undefined = obj.data_range == PixelDataBase.EMPTY_RANGE;
if any(undefined(:))
    warning('HORACE:old_file_format',....
            ['\n*** SQW file: %s\n    contains data in old binary format without pixel data averages.\n', ...
             '*** These averages are calculateing after loading pixels which may take substantial time for filebacked sqw objects\n',...
             '*** Update file format not to recalculate these averages each time the sqw file is accessed\n'],...
            obj.full_filename);
    obj = obj.recalc_data_range();
end
