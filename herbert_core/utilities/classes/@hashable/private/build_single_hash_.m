function [obj,hash,is_calculated] = build_single_hash_(obj)
% build or restore hash for single hashable object
%
is_calculated = false;
if ~isnan(obj.hash_value_)
    hash = obj.hash_value_;
    return;
end
is_calculated = true;
[obj,bytestream]    = to_hashable_array(obj);
[~,hash] = build_hash(bytestream);
obj.hash_value_ = hash;
