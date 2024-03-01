function obj = recalc_pix_range_(obj)
% recalculate common range for all pixels analysing pix ranges
% from all contributing objects
%
ranges = cellfun(@(x)(x.data_range),obj.infiles_,'UniformOutput',false);
range  = ranges{1};
for i=2:obj.nfiles
    range = minmax_ranges(range,ranges{i});
end
obj.data_range_ = range;