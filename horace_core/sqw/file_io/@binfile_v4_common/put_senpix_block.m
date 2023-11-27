function  obj = put_senpix_block(obj,img_block,pos)
%PUT_SENPIX_BLOCK stores part of image data within the boundaries of
% current image
%
% Inputs:
% obj       -- initialized instance of faccess_v4 object.
% img_block -- structure containing s,e,npix fields with information for
%              full or part of sqw or dnd image to write in the file.
% pos       -- if present, initial position of img_block within the image.
%              Counts from 0, 0 -- beginning of the image.
%

if ~obj.bat_.initialized
    error('HORACE:binfile_v4_common:runtime_error', ...
        'Attempt to put sqw block using non-initialized file-accessor')
end
if obj.file_id_ == -1
    error('HORACE:binfile_v4_common:runtime_error', ...
        'Attempt to put sqw block using file-accessor with closed or undefined sqw file: "%s "', ...
        obj.full_filename);
end
if ~(isstruct(img_block)&& isfield(img_block,'s')&&isfield(img_block,'e')&&isfield(img_block,'npix'))
    error('HORACE:binfile_v4_common:invalid_argument', ...
        'Attempt to store img_block with does not contan necessary information')
end
n_elem = numel(img_block.npix);
if ~((numel(img_block.s)==numel(img_block.e))&&numel(img_block.e) ==n_elem)
    error('HORACE:binfile_v4_common:invalid_argument', ...
        'number of elements for fields s,e,npix in the input image block must be equal')
end

img_acc_block = obj.bat_.get_data_block('bl_data_nd_data');
if pos + n_elem > img_acc_block.data_size
    error('HORACE:binfile_v4_common:invalid_argument', ...
        ['New image block will be written in pos %d and contans %d elements.\n' ...
        'Total space allocated for image contans %d elements.\n' ...
        'Attempted to write new image block beyond exisiting image boundaries'], ...
        pos,n_elem,img_acc_block.data_size);
end
s_pos    = img_acc_block.sig_position  + pos*8;
e_pos    = img_acc_block.err_position  + pos*8;
npix_pos = img_acc_block.npix_position + pos*8;

obj.move_to_position(obj.file_id_,s_pos);
fwrite(obj.file_id_,double(img_block.s(:)),'double');
obj.check_write_error(obj.file_id_,'signal');

obj.move_to_position(obj.file_id_,e_pos);
fwrite(obj.file_id_,double(img_block.e(:)),'double');
obj.check_write_error(obj.file_id_,'error');

obj.move_to_position(obj.file_id_,npix_pos);
fwrite(obj.file_id_,uint64(img_block.npix(:)),'uint64');
obj.check_write_error(obj.file_id_,'npix');
