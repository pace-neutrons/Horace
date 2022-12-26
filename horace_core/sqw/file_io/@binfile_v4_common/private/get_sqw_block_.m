function [obj,set_obj]  = get_sqw_block_(obj,block_name_or_class)
% retrieve particular data block asking for it by its name or
% class instance
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

the_data_block = obj.bat_.get_data_block(block_name_or_class);
%
[~,set_obj] = the_data_block.get_sqw_block(obj.file_id_,obj.sqw_holder);
% if sqw_holder is not empty, set updated sqw_holder
if ~isempty(obj.sqw_holder)
    obj.sqw_holder_ = set_obj;
end
