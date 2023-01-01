function obj = put_dnd_block_(obj, block_name_or_instance,varargin)
%PUT_DND_BLOCK_  store the data described by the block provided as input

if nargin>2
    check_file_defined_and_exist_(obj,'write',varargin{:});
    if ~obj.bat.initialized
        obj = obj.init(varargin{:});
    else
        obj.sqw_holder_ = varargin{1};
    end
end
obj = obj.put_sqw_block(block_name_or_instance);