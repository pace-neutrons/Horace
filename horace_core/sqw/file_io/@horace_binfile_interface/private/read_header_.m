function [stream,fid,mess] = read_header_(file_name,buf_size,varargin)
% open (reopen) file for access and read the header which allows to identify
% the file version.
% Inputs:
% file_name    -- the name of the input file to read
% buf_size     -- the number of bytes the file reader may have to read from
%                 binary file. May read more then header for further
%                 analysis for very old versions of binary sqw files
% Optional
% '-update'   -- if provided, read file in update mode.
%
% returns:
% stream      -- buf_size uint8 array of bytes of size buf_size containing
%                binary file header contents
% fid         -- Matlab identifier of the opened file with binary data
% mess        -- empty if opening and initial read of the file was
%                successful. If problem happened with operations, contains
%                message, providing information about the problem.

%
% Check if the read/write permission are required
[ok,mess,open_for_update] = parse_char_options(varargin,{'-update'});
if ~ok
    error('HORACE:horace_binfile_interface:invalid_argument',mess)
end
if open_for_update
    permission_req='rb+';   % open for reading/writing
else
    permission_req='rb';   % open for reading
end
stream = [];

% Check file and open
if isnumeric(file_name)
    [filename,permission]=fopen(file_name);
    if isempty(filename)
        mess='No open file with the given file identifier';
        return
    elseif ~strcmpi(permission,permission_req)
        mess=['Read permission of file that is already open must be ',permission_req];
        return
    end
    fid=file_name;  % copy fid
    do_fseek(fid,0,'bof');  % set the file position indicator to the start of the file
else
    fid=fopen(file_name,permission_req);
    if fid<0
        mess=['Unable to open file: ',file_name];
        return
    end
end
% read enough data to understand the file is sqw file
stream = fread(fid,buf_size,'*uint8');
if feof(fid) == 1
    mess = sprintf(['read_header_::io_error:',...
        'Can not read first %d bytes of file. File is too small to be an sqw file'],buf_size);
    return
end
[mess,res] = ferror(fid);
if res ~= 0
    error('HORACE:horace_binfile_interface:io_error',...
        'IO error reading first %d bytes of the file: Reason %s',buf_size,mess)
end
