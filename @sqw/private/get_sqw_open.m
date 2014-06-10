function [mess,filename,fid,fid_input]=get_sqw_open(file)
% Open a file for input, or check that a currently open file has correct read attributes
%
%   >> [mess,filename,fid,fid_input]=get_sqw_open(file,newfile)
%
% Input:
% ------
%   file        File name, or file identifier of open file, to which to write data
%
% Output:
% -------
%   mess        Message:
%                   - if no problem, then mess=''
%                   - if a problems contains error message
%   filename    Full name of input file 
%   fid         File identifier of file to which to write data. The insertion point is
%              always set to the beginning of the file, even for a currently open file.
%   fid_input   Identifies the status of the input file
%                   =true  if 'file' was the fid to an open file
%                   =false if 'file' was a file name


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess='';
filename='';
fid=[];
fid_input=[];

% Set the read/write permission that is required
permission_req='rb';   % open for reading

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
