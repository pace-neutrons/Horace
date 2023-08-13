function obj = check_and_set_type_(obj,val)
% CHECK_AND_SET_TYPE check input of property "type" verifies if the type is
% acceptable and set appropriate "type" property value

if ~(istext(val) && strlength(val) ==3)
    error('HORACE:sphere_proj:invalid_argument',...
        'The type parameter has to be a text string with 3 elements. It is: "%s", type: %s',...
        disp2str(val),class(val));
end
if isstring(val)
    val = val.char();
end

for i= 1:3
    let = lower(val(i));
    if ~ismember(let,obj.types_available_{i})
        error('HORACE:sphere_proj:invalid_argument',...
            'letter "%s" does not belong to the available types: ("%s") for axis N_%d',...
            let,disp2str(obj.types_available_{i}),i);
    end
    val(i) = let;
end

obj.type_ = val;
