function [obj,hash,is_calculated] = build_single_hash_(obj)
%BUILD_SINGLE_HASH_ builds or restores hash for single hashable object
% Inputs:
% obj -- hashable object.
% Returns:
% obj  -- input object modified by hash value(s) stored in hash_value_ property.
% hash -- the value of hash, defining state of the object.
%
% is_calculated
%      -- if true, the hash value was calculated for input object or 
%         some hashable sub-objects of this object
%         If false, all objects have hashes, already attached
%         to them so the function have returned the stored value.
 
is_calculated = false;
if obj.hash_defined
    hash = obj.hash_value_;
    return;
end
is_calculated = true;
[obj,bytestream]    = to_hashable_array(obj);
[~,hash] = build_hash(bytestream);
obj.hash_value_ = hash;
