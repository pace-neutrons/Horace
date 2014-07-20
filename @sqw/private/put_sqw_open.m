function [mess,filename,fid,fid_input]=put_sqw_open(file,newfile)
% Open a file for output, or check that a currently open file has correct read/write attributes
%
%   >> [mess,filename,fid,fid_input]=put_sqw_open(file)
%   >> [mess,filename,fid,fid_input]=put_sqw_open(file,newfile)
%
% Input:
% ------
%   file        File name, or file identifier of open file, to which to write data
%   newfile     File creation status (default: true):
%                   =true  if writing to a fresh file, or deleting cntents of an existing file
%                   =false if overwriting part of an existing file (w.g. if writing new header)
%
% Output:
% -------
%   mess        Message:
%                   - if no problem, then mess=''
%                   - if a problems contains error message
%   filename    Full name of output file 
%   fid         File identifier of file to which to write data. The insertion point is
%              always set to the beginning of the file, even for a currently open file.
%              Set to -1 if an error.
%   fid_input   Identifies the status of the input file
%                   =true  if 'file' was the fid to an open file
%                   =false if 'file' was a file name or an error


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess='';
filename='';
fid=-1;
fid_input=false;

% Set the read/write permission that is required
if nargin==1 || newfile
    permission_req='wb';    % Used to have 'Wb': no automatic flushing: can be faster but R2012b documnetation says use for tape
else
    permission_req='rb+';   % open for reading and writing
end

% Check file and open
if isnumeric(file)
    [filename,permission]=fopen(file);
    if isempty(filename)
        mess='No open file with the given file identifier';
        return
    elseif ~strcmpi(permission,permission_req)
        mess=['Read/write permission of file that is already open must be ',permission_req];
        return
    end
    fid=file;  % copy fid
    fid_input=true;
    frewind(fid);  % set the file position indicator to the start of the file
else
    fid=fopen(file,permission_req);
    if fid<0
        mess=['Unable to open file ',file];
        return
    end
    filename=fopen(fid);
    fid_input=false;
end
