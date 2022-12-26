function obj  = put_sqw_block_(obj,block_name_or_class,obj_to_work_with)
%
if ~obj.bat_.initialized
    error('HORACE:binfile_v4_common:runtime_error', ...
        'Attempt to get sqw block using non-initialized file-accessor')
end
if obj.file_id_ == -1
    error('HORACE:binfile_v4_common:runtime_error', ...
        'Attempt to get sqw block using file-accessor with sqw file "%s " closed', ...
        obj.full_filename);
end
if ~exist('obj_to_work_with','var')
    obj_to_work_with = obj.sqw_holder;
end

the_data_block = obj.bat_.get_data_block(block_name_or_class);
% calculate the size of the modified object
the_data_block = the_data_block.calc_obj_size(obj_to_work_with);

% find the position to store modified data block
[bat,pos,compress]  = obj.bat_.find_block_place(the_data_block);
obj.bat_ = bat;
the_data_block.position = pos;
%
the_data_block.put_sqw_block(obj.file_id_);
%
obj.bat_.put_bat(obj.file_id_);
if compress
    obj = obj.compress_file();
end