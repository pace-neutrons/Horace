function [sqw_type, ndims, mess] = get_sqw_type_from_file(infile)
% Load an sqw file from disk
%
% Syntax:
%   >> [sqw_type, ndims] = get_sqw_type_from_file(infile)
%
% Input:
% --------
%   infile      File name
%
% Output:
% --------
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents
%   ndims       Number of dimensions

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
if ~isempty(mess); fclose(fid); mess=['Error reading file type - ',mess]; return; end
if ~strcmpi(application.name,app_wrote_file.name) || application.version~=app_wrote_file.version
    fclose(fid);
    mess='Unrecognised format for sqw file';
    return
end

% Get sqw type and dimensions
[sqw_type,ndims,mess]=get_sqw_object_type(fid);
if ~isempty(mess); fclose(fid); mess=['Error reading sqw file type - ',mess]; return; end

fclose(fid);
