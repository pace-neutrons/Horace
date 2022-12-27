function [dnd_block,obj] = get_dnd_block_(obj,block_name_or_instance,varargin)
%GET_DND_BLOCK_  Retrieve the data described by the block provided as input

if nargin>2
    obj = obj.init(varargin{:});
end
%
dnd_block = obj.get_sqw_block(obj,block_name_or_instance);