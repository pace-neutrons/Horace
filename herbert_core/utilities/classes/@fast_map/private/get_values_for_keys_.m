function [val,key] = get_values_for_keys_(self,keys,no_validity_checks,mode)
%GET_VALUES_FOR_KEYS_   method retrieves values corresponding to array of keys.
%
% Using this method for array of keys is approximately
% two-three times faster than retrieving array of values
% invoking self.get(key(i)) method in a loop.
%
% Inputs:
% self  -- initialized  instance of fast map class
% keys  -- array of numerical keys
% Optional:
% no_validity_checks
%       --  if true, keys assumed to be valid and validity
%           check for keys is not performed (~5 times faster)
%           Default -- do checks.
% mode  --  2 numbers representing output modes.
%    1  - expanded. return array have size of input keys array
%         and nan values are returned for keys which are not
%         present in the map.
%    2  - compressed. Return array size equal to the number
%         of present keys and keys which do not have
%         correspondent values are omitted from the output.

if ~no_validity_checks && self.optimized_
    valid = keys<=self.min_max_key_(2) | keys<self.key_shif_;
    all_valid = false;
else
    all_valid = true;
end
n_keys = numel(keys);

key = self.key_conv_handle_(keys);
if self.optimized_
    kvo = self.keyval_optimized_;
    kvs = self.key_shif_;
    val = nan(size(key));
    if all_valid
        for idx = 1:n_keys
            val(idx) = kvo(keys(idx)-kvs);
        end
    else
        for idx = 1:n_keys
            if valid(idx)
                val(idx) = kvo(keys(idx)-kvs);
            end
        end
    end
else % non-optimized operations
    ks = self.keys_;
    val = nan(size(key));
    for i=1:n_keys
        present = ks == key(i);
        if any(present)
            val(i) = self.values_(present);
        end
    end

end
if mode > 1
    valid = ~isnan(val);
    val   = val(valid);
end
end
