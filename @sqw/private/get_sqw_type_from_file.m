function [mess, sqw_type, ndims] = get_sqw_type_from_file(infile)
% Get sqw_type and dimensionality of an sqw file on disk
%
%   >> [sqw_type, ndims, mess] = get_sqw_type_from_file(infile)
%
% Input:
% --------
%   infile      File name
%
% Output:
% --------
%   mess        Error message; blank if no errors, non-blank otherwise
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents
%   ndims       Number of dimensions

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
mess=get_application(fid,application.name);
if isempty(mess)
    % Post-prototype format sqw file
    [mess,sqw_type,ndims]=get_sqw_object_type(fid);
    if ~isempty(mess); fclose(fid); mess=['Error reading sqw file type and dimensions - ',mess]; return; end
    fclose(fid);
else
    % Assume prototype sqw file format until fails
    fclose(fid);    % close file again to restart read process in get_sqw
    [mess,main_header,header,detpar,data,position,npixtot,data_type] = get_sqw (infile, '-h');
    if ~isempty(mess); mess=['Error trying to read file as old format Horace .sqw file - ',mess]; return; end
    if ~strcmpi(data_type,'a'); mess='Error trying to read file as old format Horace .sqw file'; return; end
    sqw_type=true;
    ndims=numel(data.pax);
end
