function obj = put_dnd_block_(obj, block_name_or_instance,varargin)
%PUT_DND_BLOCK_  store the data described by the block provided as input

if nargin>2
    obj = obj.init(varargin{:});
end
obj = obj.put_sqw_block(block_name_or_instance);