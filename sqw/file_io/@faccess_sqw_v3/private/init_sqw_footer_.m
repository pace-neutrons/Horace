function obj=init_sqw_footer_(obj)
% initialize  structure, which contains all positions for different data
% fields, to be found in sqw file of appropriate version to store these
% positions on hdd for subsequent recovery for read/write operations
%
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%
%


data_block = obj.get_pos_info();

pos = obj.position_info_pos_;
form = obj.get_si_form();
[~,pos] = obj.sqw_serializer_.calculate_positions(form,data_block,pos);
% the size of the data structure is written at the end of the file so
% final position is shifted by 4 bytes
obj.eof_pos_ = pos+4;
%obj.pos_block_holder_  = data_block;


