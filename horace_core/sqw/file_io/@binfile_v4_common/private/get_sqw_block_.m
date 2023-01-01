function [obj,set_obj]  = get_sqw_block_(obj,block_name_or_class)
% retrieve particular sqw object data block asking for it by
% its name or data_block class instance.
% Inputs:
% obj          -- instance of faccess class. Either initialized
%                 or not. If not, the filename to get block
%                 from have to be provided as third argument
% block_name_or_class
%              -- the name of the data_block in BAT or the
%                 instance of data_block class, providing this
%                 name.
% Optional:
% file_name    -- the name of the file to read necessary sqw
%                 block from. The file will be opened in read
%                 mode
% Returns.
% obj          -- initialized instance of faccess_xxx_v4 reader
% set_obj      -- if initial object contains the instance of
%                 sqw/dnd object, this object, modified with
%                 the data, stored in the requested block.
%                 If the obj.sqw_holder property is empty, the
%                 retrieved instance of the requested data,
%                 obtained using the block_name requested
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
