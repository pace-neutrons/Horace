function obj = check_and_set_axes_block_(obj,val)
% check if the input value is axes block and set it if this setting is
% allowed

if ~isa(val,'axes_block')
    error('HORACE:DnDBase:invalid_argument',...
        'input for axes property has to be an axes_block only. It is %s',...
        class(val));
end
if obj.NUM_DIMS ~= val.dimensions
    error('HORACE:DnDBase:invalid_argument',...
        'number of axes dimensions is different from the number of dnd-object dimension')
end
check_combo_ = obj.axes_.do_check_combo_arg;
obj.axes_ = val;
obj.axes_.do_check_combo_arg = check_combo_;
