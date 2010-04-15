function [sqw_type, ndims, mess] = get_sqw_type_from_file(infile)
% Load an sqw file from disk
%
% Syntax:
%   >> [sqw_type, ndims, mess] = get_sqw_type_from_file(infile)
%
% Input:
% --------
%   infile      File name
%
% Output:
% --------
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents
%   ndims       Number of dimensions
%   mess        Error message; blank if no errors, non-blank otherwise

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

application=horace_version;

% Initialise output
sqw_type = [];
ndims = [];

% Open file
fid=fopen(infile,'r');
if fid<0
    mess=['Unable to open file ',infile];
    return
end

% Read application and version number
[app_wrote_file,mess]=get_application(fid);

%RAE modification - comment out 3rd part of if statement. This is because
%we got failure when trying to use v2 to read v1 data, and vice versa. In
%fact we only need to check that there is some app_wrote_file.name info.
%For pre-sqw data this info is missing, which is all we really need to
%check for.
if isempty(mess) && strcmpi(application.name,app_wrote_file.name) %&& application.version==app_wrote_file.version
    % Current version of Horace wrote file
    [sqw_type,ndims,mess]=get_sqw_object_type(fid);
    if ~isempty(mess); fclose(fid); mess=['Error reading sqw file type and dimensions - ',mess]; return; end
    fclose(fid);
else
    % Assume sqw file old format until fails
    fclose(fid);    % close file again to restart read process in get_sqw
    [main_header,header,detpar,data,mess,position,npixtot,type] = get_sqw (infile, '-h');
    if ~isempty(mess); mess=['Error trying to read file as old format Horace .sqw file - ',mess]; return; end
    if ~strcmpi(type,'a'); mess='Error trying to read file as old format Horace .sqw file'; return; end
    sqw_type=true;
    ndims=numel(data.pax);
end
