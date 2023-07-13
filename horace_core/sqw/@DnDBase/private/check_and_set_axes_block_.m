function obj = check_and_set_axes_block_(obj,val)
% check if the input value is axes block and set it if this setting is
% allowed

if ~isa(val,'AxesBlockBase')
    error('HORACE:DnDBase:invalid_argument',...
        'input for axes property has to be an AxesBlockBase only. It is %s',...
        class(val));
end
%
obj.axes_ = val;
if obj.do_check_combo_arg_
    obj = obj.check_combo_arg();
end
