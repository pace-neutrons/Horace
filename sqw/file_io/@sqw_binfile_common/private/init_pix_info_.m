function  obj = init_pix_info_(obj)
% Calculate pixels positions
%
%

data  = obj.sqw_holder_.data;
%
pix_form = obj.get_data_form('-pix_only');
pos = obj.dnd_eof_pos_;
[pix_info_pos,pos]=obj.sqw_serializer_.calculate_positions(pix_form,data,pos);


obj.urange_pos_  = pix_info_pos.urange_pos_;
obj.pix_pos_     = pix_info_pos.pix_pos_;
obj.eof_pix_pos_ = pos;
obj.npixels_ = size(data.pix,2);



