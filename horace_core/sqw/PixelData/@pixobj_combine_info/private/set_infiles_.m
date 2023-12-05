function obj = set_infiles_(obj,val)
% main setter which sets multiple pix files
% Inputs:
% val --cellarray of PixelDatBase classes
%
%
if ~iscell(val)
    error('HORACE:pixobj_combine_info:invalid_argument', ...
        'infiles property of pixobj_combine_info class accepts only cellarray of PixelData objects. Got: %s', ...
        class(val));
end
is_pix = cellfun(@(x)isa(x,'PixelDataBase'),val);
if ~any(is_pix)
    non_pix = val(~is_pix);
    idx = find(non_pix,1);
    error('HORACE:pixobj_combine_info:invalid_argument', ...
        ['infiles property of pixobj_combine_info class accepts only cellarray of PixelData objects.\n' ...
        ' First non-PixelData object N%d has class: %s'], ...
        idx,class(non_pix{1}));
end
obj.infiles_        = val;
npf = cellfun(@(x)(x.num_pixels),val);
obj.npix_each_file_ = npf(:)';
obj.num_pixels_     = sum(obj.npix_each_file_);
ranges = cellfun(@(x)(x.data_range),val,'UniformOutput',false);
range = ranges{1};
for i=2:obj.nfiles
    range = minmax_ranges(range,ranges{i});
end
obj.data_range_ = range;