function obj = check_and_set_type_(obj,val)
% CHECK_AND_SET_TYPE check input of property "type" verifies if the type is
% acceptable and set appropriate "type" property value

if ~(istext(val) && strlength(val) ==3)
    error('HORACE:CurveProjBase:invalid_argument',...
        'The type parameter has to be a text string with 3 elements. It is: "%s", type: %s',...
        disp2str(val),class(val));
end
if isstring(val)
    val = val.char();
end

for i= 1:3
    let = lower(val(i));
    if ~ismember(let,obj.curve_proj_types_{i})
        error('HORACE:CurveProjBase:invalid_argument',...
            'letter "%s" does not belong to the available types: ("%s") for axis N_%d',...
            let,disp2str(obj.curve_proj_types_{i}),i);
    end
    val(i) = let;
end
if ~isequal(obj.type_,val)
    obj.type_             = val;
    obj.img_scales_cache_ = [];
end
if obj.do_check_combo_arg
    obj = obj.check_combo_arg();
end