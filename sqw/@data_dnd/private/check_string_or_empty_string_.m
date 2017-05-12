function check_string_or_empty_string_(arg,field_name)
% Check if argument is a row character string, or an empty string

if ~(ischar(arg) && (isempty(arg)||length(size(arg))==2 && size(arg,1)==1))
    error('DATA_DND:invalid_argument',...
        'field %s has to be string or emtpy string',field_name);
end




