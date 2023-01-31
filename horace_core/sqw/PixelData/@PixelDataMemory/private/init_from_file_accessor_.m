function obj = init_from_file_accessor_(obj, f_accessor)

% Initialise a PixelData object from a file accessor
obj.data_range_ = f_accessor.get_data_range();
obj.data_ = f_accessor.get_raw_pix();
obj.full_filename = f_accessor.full_filename;
undef = obj.data_range == PixelDataBase.EMPTY_RANGE;
if any(undef(:))
    obj = recalc_data_range(obj);
end

