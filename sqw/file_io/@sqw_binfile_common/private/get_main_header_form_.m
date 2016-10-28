function header = get_main_header_form_(varargin)
% get main header format

[ok,mess,update]=parse_char_options(varargin,{'-update'});
if ~ok
    error('SQW_BINILE_COMMON:invalid_argument',mess);
end
if update
    header = struct('nfiles',int32(1));
else
    header = struct('filename','','filepath','','title','',...
        'nfiles',int32(1));
end
