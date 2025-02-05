function obj = optimize_(obj)
%OPTIMIZE_  % place values into expanded array or cellarray, containing
% NaN or empty where keys are missing and values where
% keys are present. This array/cellarray is optimal for fast
% access to the values as function of keys.

obj.min_max_key_val_ = min_max(obj.keys_);
obj.key_shif_ = obj.min_max_key_val_(1)-1;
n_places = obj.min_max_key_val_(2)-obj.min_max_key_val_(1)+1;
obj.keyval_optimized_ = nan(1,n_places);
keys_shifted = obj.keys_-obj.min_max_key_val_(1)+1;
obj.keyval_optimized_(keys_shifted) = obj.values_(:);
obj.optimized_ = true;
