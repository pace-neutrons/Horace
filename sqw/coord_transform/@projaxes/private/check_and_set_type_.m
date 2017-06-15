function obj = check_and_set_type_(obj,type)
% Verify if type argument set to projaxes class is correct
% and set type variable if it does
%
persistent old_matlab;
if isempty(old_matlab)
    old_matlab = verLessThan('Matlab','9.1');
end

ok=true;
mess = '';
if is_string(type) && numel(type)==3
    type=lower(type);
    if old_matlab
        if ~(isempty(strfind('arp',type(1))) || isempty(strfind('arp',type(2))) || isempty(strfind('arp',type(1))))
            return
        else
            mess='Normalisation type for each axis must be ''r'', ''p'' or ''a''';
            ok=false;
        end
    else
        if ~(contains('arp',type(1)) && contains('arp',type(2)) && contains('arp',type(3)))
            mess='Normalisation type for each axis must be ''r'', ''p'' or ''a''';
            ok=false;
        end
    end
else
    mess='Normalisation type must be a three character string, ''r'', ''p'' or ''a'' for each axis';
    ok=false;
end

if ~ok
    error('PROJAXEX:invalid_argument',mess)
end
obj.type_ = type;



