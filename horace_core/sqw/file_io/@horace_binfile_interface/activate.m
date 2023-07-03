function obj = activate(obj, read_or_write)
% Open respective file in read or write mode without reading any
% supplementary file information. Assume that header information
% stored on this object is correct.
%
% Can be used for MPI transfers between workers when open file can
% not be transferred between workers but everything else can
%
% Input
% -----
%
% read_or_write   Char array. If 'read' open the file in read-only
%                 mode If 'write' open the file in read/write mode.
%                 Default is 'read'.
%
if nargin == 1
    read_or_write = 'read';
end
permission = get_fopen_permission_(read_or_write);

if ~isempty(obj.file_closer_)
    obj.file_closer_ = [];
end

obj.file_id_ = fopen(obj.full_filename, permission,'l','Windows-1252');
if obj.file_id_ < 1
    error('HORACE:horace_binfile_interface:runtime_error',...
        'Can not open file %s at location %s',...
        obj.filename,obj.filepath);
end
obj.file_closer_ = onCleanup(@()fclose(obj));


function permission = get_fopen_permission_(permission)
% Convert char arrays 'read' or 'write' into fopen file permissions
if strcmpi(permission, 'read')
    permission = 'rb';
elseif strcmpi(permission, 'write')
    permission = 'rb+';
else
    error('HORACE:horace_binfile_interface:invalid_argument', ...
        ['Invalid input for read_or_write. Must be ''read'' or ''write''. ' ...
        'Found ''%s'''], permission);
end

