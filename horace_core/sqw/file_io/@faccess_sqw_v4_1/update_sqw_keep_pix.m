function  obj = update_sqw_keep_pix(obj)
% Given initialized sqw object in memory, initialized BAT and sqw file
% written in old file format, write everything in memory to proper places
% in file keeping pixels data on their original place
%
% Usage:
% obj = obj.update_sqw_keep_pix()
% Put sqw object which have been already initialized at sqw holder



obj = obj.put_all_blocks('ignore_blocks','bl_pix_data_wrap');
% get the block responsible for pixel position
pix_block = obj.bat_.blocks_list{end};
% put again the information about pixel block size and shape
pix_block.put_data_header(obj.file_id_);