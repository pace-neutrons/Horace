function  obj = check_combo_arg_(obj)
%CHECK_COMBO_ARG_ validate consistency of interdependent properties, namely
%key/value properties. If conditions right, the function also builds
%cash for optimized access to values

if numel(obj.keys_) ~= numel(obj.values_)
    error('HERBERT:fast_map:invalid_argument', ...
        'Number of keys (%d) and number of values (%d) must be equal',...
        numel(obj.keys_),numel(obj.values_))
end
if ~isa(obj.keys_,obj.key_type_)
    obj.keys_     = obj.key_conv_handle_(obj.keys_);
end

obj.min_max_key_ = min_max(obj.keys_);
% always optimize if key spread is smaller then the specified number
if ~isempty(obj.min_max_key_) && (obj.min_max_key_(2)-obj.min_max_key_(1) <= obj.empty_space_optimization_limit * obj.n_members)
    obj.optimized = true;
end

end