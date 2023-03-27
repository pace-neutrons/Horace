function obj = check_and_set_type_(obj,type)
% Verify if type argument set to projaxes class is correct
% and set type variable if it does

if is_string(type) && numel(type)==3
    type=lower(type);
    if any(arrayfun(@(t)(~contains('arp', t)), type))
        error('HORACE:ortho_proj:invalid_argument', ...
            'Normalisation type for each axis must be ''r'', ''p'' or ''a''. Provided: %s',...
            type)
    end
    obj.type_ = type;
else
    error('HORACE:ortho_proj:invalid_argument', ...
        'Normalisation type must be a three character string, ''r'', ''p'' or ''a'' for each axis. Provided: %s',...
        evalc('disp(type)'))
end
