function  obj = check_combo_arg_(obj)
%CHECK_COMBO_ARG_ validate consistency of interdependent properties, namely
%key/value properties. If conditions right, the function also builds
%cash for optimized access to values

if numel(obj.keys_) ~= numel(obj.values_)
    error('HERBERT:fast_map:invalid_argument', ...
        'Number of keys (%d) and number of values (%d) must be equal',...
        numel(obj.keys_),numel(obj.values_))
end

obj.min_max_key_val_ = min_max(obj.keys_);
% always optimiza if key spread is bigger then specified number
if obj.min_max_key_val_(2)-obj.min_max_key_val_(1) <= obj.empty_space_optimization_limit * obj.n_members
    obj.optimized = true;
end

end