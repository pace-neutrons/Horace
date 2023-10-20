function obj = set_full_filename_(obj,val)
% main setter for full sqw object filename
if ~(isstring(val)||ischar(val))
    error('HORACE:sqw:invalid_argument', ...
        ' Full filename can be only string, describing input file together with the path to this file. It is: %s', ...
        disp2str(val));
end
obj.main_header.full_filename = val;
obj.data.full_filename = val;
obj.pix.full_filename = val;
