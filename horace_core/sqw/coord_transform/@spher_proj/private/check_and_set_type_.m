function obj = check_and_set_type_(obj,val)
%CHECK_AND_SET_TYPE check input of type properties, verify if it is
%acceptable and set appropriate type property

if ~(istext(val) && strlength(val) ==3)
    error('HORACE:spher_proj:invalid_argument',...
        'The type parameter has to be a text string with 3 elements. It is: "%s"',...
        disp2str(val));
end
if isstring(val)
    val = val.char();
end
for i= 1:3
    let = lower(val(i));
    if ~ismember(let,obj.types_available_{i})
        error('HORACE:spher_proj:invalid_argument',...
            'letter %s does not belong to the available types ("%s") for axis N%d',...
            let,disp2str(obj.types_available_{i}),i);
    end
    val(i) = let;
end


obj.type_ = val;
