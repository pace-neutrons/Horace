function  npix = get_npix_block(obj,pos_start,pos_end)
% Read all or partial npix information describing distribution of pixels
% over the bins.
%
% Usage:
%>>data_struct = obj.get_npix_block(pos_start,pos_end);
% Inputs:
% pos_start  -- the number of the first elment of the npix array to read
% pos_end    -- the number of the last element of the npix array to read


if ~obj.bat_.initialized
    error('HORACE:binfile_v4_common:runtime_error', ...
        'Attempt to get npix data using non-initialized file-accessor')
end
if obj.file_id_ == -1
    error('HORACE:binfile_v4_common:runtime_error', ...
        'Attempt to get npix data using file-accessor with closed or undefined sqw file: "%s "', ...
        obj.full_filename);
end

n_elem = pos_end - pos_start+1;
img_acc_block = obj.bat_.get_data_block('bl_data_nd_data');
if pos_start > pos_end || n_elem > img_acc_block.data_size
    error('HORACE:binfile_v4_common:invalid_argument', ...
        ['Attempt to read npix data from pos: %d to pos: %d\n' ...
        'The existing npix  block contains %d elements.\n' ...
        'Read goes outside of the ranges of the npix block\n'], ...
        pos_start,pos_end,n_elem);
end

npix_pos = img_acc_block.npix_position + (pos_start-1)*8;

obj.move_to_position(obj.file_id_,npix_pos);
npix = fread(obj.file_id_,n_elem,'uint64');
obj.check_read_error(obj.file_id_,'npix');
