function obj=set_prop_(obj, fld, val)
%SET_PROP_  Main part of PixelDataFileBacked property setter.
%

if obj.read_only
    error('HORACE:PixelDataFileBacked:invalid_argument',...
        'File %s is opened in read-only mode. Can not change its properties', obj.full_filename);
end
val = check_set_prop(obj,fld,val);

[pix_idx_start,pix_idx_end] = obj.get_page_idx_(obj.page_num_);
pix_idx_end = min(pix_idx_end,pix_idx_start-1+size(val,2));
indx = pix_idx_start:pix_idx_end;
flds = obj.FIELD_INDEX_MAP_(fld);
obj.f_accessor_.Data.data(flds, indx) = single(val);

% setting data property value removes misalignment. We do not
% consciously set misaligned data
if obj.is_misaligned_
    obj.is_misaligned_ = false;
    obj.alignment_matr_= eye(3);
end
%
obj = obj.invalidate_range(fld);
