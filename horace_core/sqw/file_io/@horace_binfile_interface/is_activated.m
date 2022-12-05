function is = is_activated(obj, read_or_write)
% Check if the file-accessor is bound to an open binary file
%
% Input
% -----
%
% read_or_write   Char array. If 'read' return true if file is open
%                 for reading. If 'write' return true if file is
%                 open for writing.
%
full_file_path = obj.full_filename;
[file_id_path, permission] = fopen(obj.file_id_);
is = strcmp(full_file_path, file_id_path);

if is && nargin == 2
    if strcmpi(read_or_write, 'read')
        READ_MODE_REGEX = '([ra]b\+?)|(wb\+)';
        open_for_reading = regexp(permission, READ_MODE_REGEX, 'once');
        is = ~isempty(open_for_reading);
    elseif strcmpi(read_or_write, 'write')
        WRITE_MODE_REGEX = '([WAaw]b\+?)|(rb\+)';
        open_for_writing = regexp(permission, WRITE_MODE_REGEX, 'once');
        is = ~isempty(open_for_writing);
    else
        error('HORACE:horace_binfile_interface:invalid_argument',...
            ['Invalid input for read_or_write. Must be ''read'' ', ...
            'or ''write'', found ''%s'''], read_or_write);
    end
end
