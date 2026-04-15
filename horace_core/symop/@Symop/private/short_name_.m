function short_name = short_name_(op_name)
% cut the name of input operation up to minimal recognizable
% name
if isstring(op_name)
    op_name = char(op_name);
elseif ~ischar(op_name)
    error('HORACE:Symop:invalid_argument', ...
        'Operation name should be defined by text string. Received class %s', ...
        class(op_name));
end
if upper(op_name(1))=='R'
    short_name = upper(op_name(1:2));
else
    short_name = upper(op_name(1));
end
end
