function obj = set_pos_npix_start_(obj,val)
%SET_POS_NPIX_START_ Accepts non-negative array of positions of npix 
% distributions in each file or single value if the positions of all npix
% in all files are the same
if ~isnumeric(val) || any(val<0)
    error('HORACE:pixfile_combine_info:invalid_argument',...
        'pos_npixstart has to be non-negative numeric array containing information about npix location on hdd')
end
obj.pos_npixstart_ = val(:)';
if numel(val) == 1 % each contributing file has npix array
    % located at the same position
    obj.pos_npixstart_ = ones(1,obj.nfiles)*val;
end
if obj.do_check_combo_arg_
    obj = check_combo_arg(obj);
end
