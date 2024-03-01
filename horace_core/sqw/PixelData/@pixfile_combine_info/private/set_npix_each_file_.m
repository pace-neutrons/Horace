function obj = set_npix_each_file_(obj,val)
%SET_NPIX_EACH_FILE_ main setter of npix property.
%
% Sets the numeric array which defines number of pixels in each file
% Can provide it as whole array or single value if total number of pixels
% in each file is the same.

if ~isnumeric(val) || any(val<0)
    error('HORACE:pixfile_combine_info:invalid_argument',...
        'npix_each_file has to be numeric array containing information about number of pixels in each file')
end
obj.npix_each_file_ = val(:)';
if numel(val) == 1 % each contributing file has npix array
    % of the same size.
    obj.npix_each_file_ = ones(1,obj.nfiles)*val;
end
obj.num_pixels_ = uint64(sum(obj.npix_each_file_));
if obj.do_check_combo_arg_
    obj = check_combo_arg(obj);
end
