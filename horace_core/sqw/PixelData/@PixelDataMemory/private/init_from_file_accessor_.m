function obj = init_from_file_accessor_(obj, f_accessor)
% Initialise a PixelDataMemory object from a file accessor
%
meta  = f_accessor.get_pix_metadata();
% set up current filename, instead of stored with metadata
meta.full_filename = f_accessor.full_filename;
obj.metadata = meta;
obj.data_ = f_accessor.get_raw_pix();
ver = f_accessor.faccess_version;
if ver < 4.0
    recacl_unique_run_id = true;
    obj.old_file_format_ = true;
else
    recacl_unique_run_id = false;
end

if ~obj.is_range_valid() || recacl_unique_run_id
    if recacl_unique_run_id
        [obj,obj.unique_run_id_] = recalc_data_range(obj);
    else
        obj = recalc_data_range(obj);
    end
end
