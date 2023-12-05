function obj = set_pos_pixstart_(obj,val)
% SET_POS_PIXSTART_ Main setter for the positions of pixels in binary file
% Accepts positive array of positions of pixels in each file or single
% value if the position of all pixels in all files is the same

if ~isnumeric(val)
    error('HORACE:pixfile_combine_info:invalid_argument',...
        'pos_pixstart has to be numeric array containing information about pix location on hdd')
end
obj.pos_pixstart_ = val(:)';
if numel(val) == 1 % each contributing file has pixels data
    % located at the same position
    obj.pos_pixstart_  = ones(1,obj.nfiles)*val;
end
if obj.do_check_combo_arg_
    obj = check_combo_arg(obj);
end
