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
% $Revision$ ($Date$)

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

if isempty(mess) && strcmpi(application.name,app_wrote_file.name) && application.version==app_wrote_file.version
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
