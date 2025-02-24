function obj = optimize_(obj,minmax_keys)
%OPTIMIZE_  % place values into expanded array or cellarray, containing
% NaN or empty where keys are missing and values where
% keys are present. This array/cellarray is optimal for fast
% access to the values as function of keys.


obj.min_max_key_ = minmax_keys;
obj.key_shif_        = obj.min_max_key_(1)-1;

n_places = obj.min_max_key_(2)-obj.min_max_key_(1)+1;

val_optimized = nan(1,n_places);

if ~isempty(obj.values_)
    keys_shifted = obj.keys_-obj.min_max_key_(1)+1;    
    val = obj.values_;
    val_optimized(keys_shifted) = val(:);
end

obj.keyval_optimized_ = val_optimized;

obj.optimized_ = true;
