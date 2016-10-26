function [stream,fid,mess] = get_header_(file,varargin)
% open (reopen) file for acces read the header, which allows to identify
% the filie version
%
% returns:
% uint8 array of bytes -- binary contents of the file
%
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
%

%
% Set the read/write permission that is required
permission_req='rb';   % open for reading
stream = [];
if nargin> 1
    buf_size = varargin{1};
else
    buf_size =4+6+8+4+4;
end

% Check file and open
if isnumeric(file)
    [filename,permission]=fopen(file);
    if isempty(filename)
        mess='No open file with the given file identifier';
        return
    elseif ~strcmpi(permission,permission_req)
        mess=['Read permission of file that is already open must be ',permission_req];
        return
    end
    fid=file;  % copy fid
    frewind(fid);  % set the file position indicator to the start of the file
else
    fid=fopen(file,permission_req);
    if fid<0
        mess=['Unable to open file: ',file];
        return
    end
end
% read enough data to understand the file is sqw file
stream = fread(fid,buf_size,'*uint8');
if feof(fid) == 1
    mess = sprintf(['DND_FILE_INTERFACE:io_error:',...
        'Can not read first %d bytes of file. File is too small to be an sqw file'],buf_size);
    return
end
[mess,res] = ferror(fid);
if res ~= 0
    error('DND_FILE_INTERFACE:io_error',...
        'IO error reading first %d bytes of the file: Reason %s',buf_size,mess)
end

