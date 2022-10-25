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
    pix_form = rmfield(pix_form,'pix_block');
    dat = obj.sqw_holder_.data;
    % The oddity in old sqw data format -- the range of data is
    % stored only when pixels are stored. Here we estimate the size of pixel
    % header and calculate the position where the combined pixels will be
    % stored
    [pix_info_pos,pos]=obj.sqw_serializer_.calculate_positions(pix_form,dat,pos);
    pix_info_pos.pix_block_pos_ = pos;
    npix = pix.num_pixels;
    % Calculate the size of the combined pixels array from knowlege of the
    % number of pixels in every file
    % start of npix pos + npix+ pix info size (single precision array of
    % 8 x npix)
    pos = pos + 8 + npix*9*4;
    obj.npixels_ = npix;
else
    pix_info = pix_form;
    pix_info.img_range  = single(ones(2,4));
    pix_info.dummy = single(1);
    pix_info.pix_block = pix;
    [pix_info_pos,pos]=obj.sqw_serializer_.calculate_positions(pix_form,pix_info,pos);
    obj.npixels_ = pix.num_pixels;
end


obj.img_db_range_pos_  = pix_info_pos.img_range_pos_;
obj.pix_pos_        = pix_info_pos.pix_block_pos_ + 8; % serializer calculates pix position
% at the position of the npix as it is part of the pix field.
% As we access pixels directly via its position, here we adjust this value
% to the beginning of the real pix array.
%
obj.eof_pix_pos_ = pos;

