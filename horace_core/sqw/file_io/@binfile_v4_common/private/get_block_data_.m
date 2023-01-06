function [dnd_block,obj] = get_block_data_(obj,block_name_or_instance,varargin)
%GET_DND_BLOCK_  Retrieve the data described by the block provided as input

if nargin>2
    check_file_defined_and_exist_(obj,'read',varargin{:});
    obj = obj.init(varargin{:});
end
%
[obj,dnd_block] = obj.get_sqw_block(block_name_or_instance);