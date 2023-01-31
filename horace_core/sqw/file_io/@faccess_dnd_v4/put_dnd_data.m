function obj = put_dnd_data(obj,varargin)
%PUT_DND_DATA store information, containing dnd image arrays

obj = put_dnd_block_(obj, ...
     faccess_dnd_v4.dnd_blocks_list_{2},varargin{:});