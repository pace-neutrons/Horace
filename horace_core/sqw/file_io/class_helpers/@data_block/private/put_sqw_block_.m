function obj = put_sqw_block_(obj,fid,sqw_obj,check_size)
% extract sub-block information from sqw or dnd object and write
% this information on HDD
% Inputs:
% obj     -- initialized instance of data_block
% fid     -- handle for binary file opened for write access
% Optional:
% sqw_obj -- if present, the data to save should be taken from the
%            object provided
% check_size
%         -- if true, expect that the object size
%            has been precalculated earlier and now we want to
%            ectract binary data from the input object. Does
%            check if the size of binary data in the object
%            still equal to size precalculated earlier. Throws
%            if this does not happen
%
if ~isempty(sqw_obj)
    obj = obj.calc_obj_size(sqw_obj,false,check_size);
else
    if isempty(obj.serialized_obj_cache_)
        error('HORACE:data_block:runtime_error',...
            ['put_data_block is called without sqw object argument, ', ...
            'but the size of the object has not been set ', ...
            'and the object cache is empty']);
    end
end
bindata = obj.serialized_obj_cache_;
if isa(bindata,'uint8')
    if (numel(bindata) > obj.size)
        error('HORACE:data_block:runtime_error',...
            'Pre-calculated block size %d differs from obtained block size %d. Binary file will be probably corrupted',...
            obj.block_size,numel(bindata))
    else
        obj.size_=uint64(numel(bindata));
    end
end
obj = obj.put_bindata_in_file(fid,bindata);
obj.serialized_obj_cache_ = [];

