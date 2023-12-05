function obj = set_pos_npix_start_(obj,val)
%SET_POS_NPIX_START_ Accepts positive array of positions of pix distributon
% in each file or single value if the position of all pixels in
% all files is the same
if ~isnumeric(val)
    error('HORACE:pixfile_combine_info:invalid_argument',...
        'pos_npixstart has to be numeric array containing information about npix location on hdd')
end
obj.pos_npixstart_ = val(:)';
if numel(val) == 1 % each contributing file has npix array
    % located at the same position
    obj.pos_npixstart_ = ones(1,obj.nfiles)*val;
end
if obj.do_check_combo_arg_
    obj = check_combo_arg(obj);
end
