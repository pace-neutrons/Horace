function obj = check_and_set_type_(obj,type)
% Verify if type argument set to projaxes class is correct
% and set type variable if it does

ok=true;
mess = '';
if is_string(type) && numel(type)==3
    type=lower(type);
    if isempty(strfind('arp',type(1))) || isempty(strfind('arp',type(2))) || isempty(strfind('arp',type(1)))
        mess='Normalisation type for each axis must be ''r'', ''p'' or ''a''';
        ok=false;
    end
    obj.type_ = type;
else
    mess='Normalisation type must be a three character string, ''r'', ''p'' or ''a'' for each axis';
    ok=false;
end

if ~ok
    error('PROJAXES:invalid_argument',mess)
end
