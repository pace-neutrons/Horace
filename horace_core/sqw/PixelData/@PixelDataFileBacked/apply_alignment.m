function  obj = apply_alignment(obj)
%APPLY_ALIGNMENT align pixels according to the alignment matrix attached to
% pixels and clear alignment information

if ~obj.is_misaligned
    % nothing to do
    return;
end
obj = obj.prepare_dump();

[ll,fm]  = config_store.instance().get_value('hor_config', ...
    'log_level','fb_scale_factor');
obj.data_range = obj.EMPTY_RANGE;
if ll> 0
    fprintf('*** Applying alignment for pixels in file: %s\n', ...
        obj.full_filename);
end

npages = obj.num_pages;
npr = 0;
for pg = 1:npages
    obj.page_num = pg;
    if ll> 0 && npr<1
        fprintf('*** processing page %d/%d\n',pg,npages)
    end

    data = obj.data;

    obj = obj.format_dump_data(data);
    obj.data_range = ...
        obj.pix_minmax_ranges(data, obj.data_range_);
    npr = npr+1;
    if npr>=fm
        npr = 0;
    end
end
obj.alignment_matr_  = eye(3);
obj.is_misaligned_   = false;
obj = obj.finish_dump();
