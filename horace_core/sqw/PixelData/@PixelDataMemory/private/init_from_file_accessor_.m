function obj = init_from_file_accessor_(obj, f_accessor)
% Initialise a PixelDataMemory object from a file accessor
%
meta  = f_accessor.get_pix_metadata();
% set up current filename, instead of stored with metadata
meta.full_filename = f_accessor.full_filename;
obj.metadata = meta;
obj.data_ = f_accessor.get_raw_pix();
if ~obj.is_range_valid()
    obj = recalc_data_range(obj);
end
