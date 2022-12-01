function permission = get_fopen_permission_(permission)
% Convert char arrays 'read' or 'write' into fopen file permissions
if strcmpi(permission, 'read')
    permission = 'rb';
elseif strcmpi(permission, 'write')
    permission = 'rb+';
else
    error('HORACE:dnd_binfile_common:invalid_argument', ...
        ['Invalid input for read_or_write. Must be ''read'' or ''write''. ' ...
        'Found ''%s'''], permission);
end

