function obj = recalc_pix_range_(obj)
% recalculate common range for all pixels analysing pix ranges
% from all contributing files
%
n_files = obj.nfiles;
ldr_list = cell(1,n_files);
for i=1:n_files
    ldr_list{i} = sqw_formats_factory.instance().get_loader(obj.infiles{i});
end
%
obj.data_range_ = pix_combine_info.recalc_data_range_from_loaders(ldr_list);
%
for i=1:n_files
    ldr_list{i}.delete();
end