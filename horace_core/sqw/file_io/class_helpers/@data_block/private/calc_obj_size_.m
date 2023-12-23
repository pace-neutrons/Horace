function obj = calc_obj_size_(obj,sqw_obj,nocache,check_size)
%CALC_OBJ_SIZE_ Calculates size of the serialized sqw/dnd sub-object and put
% the serialized sub-object into data cache for subsequent put operation(s)
%
% Inputs:
% obj     -- instance of data block class
% sqw_obj -- sqw/dnd object - source of data for this
%            data_block
% nocache  -- if present and true do not serialize object for
%             evaluating its size and placing serialized array
%             into cache but use serializable.serial_size
%             method to find the object size.
% check_size
%          -- if present and true, assumes that the size and
%             position of the object was identified before
%             (e.g. using nocache option) and are all known.
%             Сhecks serialized size of the object against the
%             size of the array calculated while serializing
%             to ensure that precaclulatrions were performed
%             correctly.
%
subobj = obj.get_subobj(sqw_obj);
is_serial = isa(subobj,'serializable');
if nocache && is_serial
    obj.size_ = subobj.serial_size();
else
    if is_serial
        bindata = subobj.serialize();
    else
        bindata = serialize(subobj);
    end
    if check_size
        if obj.size_ ~= numel(bindata)
            error('HORACE:data_block:runtime_error', ...
                'size of the ')
        end
    else
        obj.size_ = numel(bindata);
    end
    if nocache; return; end
    obj.serialized_obj_cache_ = bindata;
end
