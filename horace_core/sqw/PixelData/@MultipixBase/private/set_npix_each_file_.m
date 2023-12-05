function obj = set_npix_each_file_(obj,val)
%SET_NPIX_EACH_FILE_ main setter of npix property.
% Sets the numeric array which defines number of pixels in each file or
% signle value if total number of pixels in each file is the same
if ~isnumeric(val)
    error('HORACE:pixfile_combine_info:invalid_argument',...
        'pos_npixstart has to be numeric array containing information about npix location on hdd')
end
obj.npix_each_file_ = val(:)';
if numel(val) == 1 % each contributing file has npix array
    % located at the same position
    obj.npix_each_file_ = ones(1,obj.nfiles)*val;
end
obj.num_pixels_ = uint64(sum(obj.npix_each_file_));
if obj.do_check_combo_arg_
    obj = check_combo_arg(obj);
end
