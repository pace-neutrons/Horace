function  obj = init_pix_info_(obj)
% Initialize the pixels positions of sqw file for subsequent write operations
% using sqw object, stored in memory.
%
%

pix  = obj.sqw_holder_.pix;
%
pix_form = obj.get_pix_form();
pos = obj.dnd_eof_pos_;
if isa(pix,'pix_combine_info') % data contains not pixels themselves but input for
    % combining pixels from multiple files together.
    [pix_info_pos,pos]=obj.sqw_serializer_.calculate_positions(pix_form,PixelData,pos);
    pix_info_pos.pix_pos_ = pos;
    npix = pix.num_pixels;
    % start of npix pos + npix+ pix info size (single precision array of
    % 8 x npix)
    pos = pos + 8 + npix*9*4;
    obj.npixels_ = npix;
else
    [pix_info_pos,pos]=obj.sqw_serializer_.calculate_positions(pix_form,pix,pos);
    obj.npixels_ = pix.num_pixels;
end



obj.img_db_range_pos_  = pix_info_pos.img_range_pos_;
obj.pix_pos_        = pix_info_pos.data_pos_+8; % serializer calculates pix position
% at the position of the npix as it is part of the pix field.
% As we access pixels directly via its position, here we adjust this value
% to the beginning of the real pix array.
%
obj.eof_pix_pos_ = pos;

