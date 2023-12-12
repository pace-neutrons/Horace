function pix_data = get_raw_pix_(obj,n_file,pix_pos_start,pix_pos_end)
% read pixel block of the appropriate size located at the
% specified position in the binary file
%Inputs:
% n_file       -- the number of object to read
% pos_pixstart -- the initial position of the pix block to read
% pix_pos_end  -- final poistion of pixels to read

fid = obj.loaders_list_{n_file};
npix_to_read = pix_pos_end-pos_pix_start+1;
pix_pos_start = obj.pos_pixstart_(n_file) + (pix_pos_start-1)*9*4;

do_fseek(fid,pix_pos_start,'bof');
[pix_data,count_out] = fread(fid,[9,npix_to_read],'*float32');
if count_out ~=9*npix_to_read
    error('HORACE:pixfile_combine_info:io_error',...
        ' Number of pixels read from file (%d) is smaller then the number requested: %d',...
        count_out/9,npix_to_read);
end
[f_message,f_errnum] = ferror(fid);
if f_errnum ~=0
    error('HORACE:pixfile_combine_info:io_error',...
        'Error N%d during IO operation: %s',f_errnum,f_message);
end
