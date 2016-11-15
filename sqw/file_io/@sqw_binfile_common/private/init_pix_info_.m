function  obj = init_pix_info_(obj)
% Initialize the pixels positions of sqw file for subsequent write operations
% using sqw object, stored in memory.
%
%
%
% $Revision$ ($Date$)
%


data  = obj.sqw_holder_.data;
%
pix_form = obj.get_data_form('-pix_only');
pos = obj.dnd_eof_pos_;
if isa(data.pix,'pix_combine_info') % data contains not pixels themselves but input for
    % combining pixels from multiple files together.
    pix_form = rmfield(pix_form,'pix');
    [pix_info_pos,pos]=obj.sqw_serializer_.calculate_positions(pix_form,data,pos);
    obj.pix_pos_ = pos;
    npix = data.pix.npixels;
    pos = pos + npix*9*4;
    obj.npixels_ = npix;
else
    [pix_info_pos,pos]=obj.sqw_serializer_.calculate_positions(pix_form,data,pos);
    obj.npixels_ = size(data.pix,2);
end



obj.urange_pos_  = pix_info_pos.urange_pos_;
obj.pix_pos_     = pix_info_pos.pix_pos_+8; % serializer calculates pix position
% at the position of the npix as it is part of the pix field.
% As we access pixels directly via its position, here we adjust this value
% to the beginning of the real pix array.
%
obj.eof_pix_pos_ = pos;


