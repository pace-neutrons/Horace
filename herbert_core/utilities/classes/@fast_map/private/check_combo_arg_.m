function  obj = check_combo_arg_(obj)
%CHECK_COMBO_ARG_ validate consistency of interdependent properties, namely
%key/value properties

if numel(obj.keys_) ~= numel(obj.values_)
    error('HERBERT:fast_map:invalid_argument', ...
        'Number of keys (%d) and number of values (%d) must be equal',...
        numel(obj.keys_),numel(obj.values_))
end

obj.min_max_key_val_ = min_max(obj.keys_);

end