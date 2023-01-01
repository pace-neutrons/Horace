function obj  = put_sqw_block_(obj,block_name_or_instance,obj_to_work_with)
% store modified particular sqw sub-object data block within the
% sqw object binary records on hdd
% Inputs:
% obj          -- instance of faccess class. Either initialized
%                 or not. If not, the information for the initialization
%                 have to be provided as subsequent arguments
% block_name_or_class
%              -- the registered data_block name or
%                 instance-source of the data_block name to
%                 use for storing the requested data on hdd
%Optional:
% Either:
% sqw_object   -- the instance of SQWDnDBase class to extract
%                 modified subobject from
% OR:
% subobj       -- the subobject of sqw object to store using selected
%                 data_block
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
if ~exist('obj_to_work_with','var')
    obj_to_work_with = obj.sqw_holder;
end

the_data_block = obj.bat_.get_data_block(block_name_or_instance);
% calculate the size of the modified object and fill block cache with
% serialized block contents
the_data_block = the_data_block.calc_obj_size(obj_to_work_with);

% find the place to store provided data block
[bat,pos,compress]  = obj.bat_.find_block_place(the_data_block);
% keep modified BAT
obj.bat_ = bat;
the_data_block.position = pos;
% store block
the_data_block.put_sqw_block(obj.file_id_);
% store modified BAT.
obj.bat_.put_bat(obj.file_id_);
% if file compression is necessary, compress file on hdd
if compress
    obj = obj.compress_file();
end