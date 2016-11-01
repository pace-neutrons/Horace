function obj=init_footer_(obj)
% initalize structure, which contains all positions for different data
% fields, to be found in sqw file of appropriate version to store these
% positions on hdd for subsequent recovery for read/write operations

fields2save = obj.fields_to_save();
data_block = struct('data_type',obj.data_type);
for i=1:numel(fields2save)
    fld = fields2save{i};
    data_block.(fld) = obj.(fld);
end

pos = obj.position_info_pos_;
form = obj.get_is_form();
[~,pos] = obj.sqw_serializer_.calculate_positions(form,data_block,pos);
% the size of the data structure is writtern at the end of the file so 
% final position is shifted by 4 bytes
obj.eof_pos_ = pos+4;
%obj.pos_block_holder_  = data_block;


