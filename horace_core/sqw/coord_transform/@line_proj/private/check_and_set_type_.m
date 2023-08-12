function obj = check_and_set_type_(obj,type)
% Verify if type argument set to projaxes class is correct
% and set type variable if it does

if isempty(type)
    obj.type_is_defined_explicitly_ = false;
    obj.type_ = 'ppr';
    return;
end

if is_string(type) && numel(type)==3
    type=lower(type);
    if any(arrayfun(@(t)(~contains('arp', t)), type))
        error('HORACE:line_proj:invalid_argument', ...
            'Normalisation type for each axis must be ''r'', ''p'' or ''a''. Provided: %s',...
            type)
    end
    obj.type_ = type;
else
    error('HORACE:line_proj:invalid_argument', ...
        'Normalisation type must be a three character string, ''r'', ''p'' or ''a'' for each axis. Provided: %s',...
        disp2str(type))
end
obj.type_is_defined_explicitly_ = true;
