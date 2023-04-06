function obj = init_from_file_accessor_(obj, f_accessor)

% Initialise a PixelData object from a file accessor
meta  = f_accessor.get_pix_metadata();
% set up current filename, instead of stored with metadata
meta.full_filename = f_accessor.full_filename;
obj.metadata = meta;
obj.data_ = f_accessor.get_raw_pix();
undef = obj.data_range == PixelDataBase.EMPTY_RANGE;
if any(undef(:))
    obj = recalc_data_range(obj);
end
