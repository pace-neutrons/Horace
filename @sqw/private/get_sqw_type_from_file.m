function [mess, sqw_type, ndims, nfiles] = get_sqw_type_from_file(infile)
% Get sqw_type and dimensionality of an sqw file on disk
%
%   >> [mess, sqw_type, ndims, nfiles] = get_sqw_type_from_file (infile)
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
%   nfiles      Number of contributing spe data sets (=0 if not sqw-type)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

application=horace_version;

% Initialise output
sqw_type = [];
ndims = [];
nfiles = [];

% Open file
[mess,filename,fid]=get_sqw_open(infile);
if fid<0, return, end

% Read application and version number
mess=get_application(fid,application.name);
if isempty(mess)
    % Post-prototype format sqw file
    [mess,sqw_type,ndims]=get_sqw_object_type(fid);
    if ~isempty(mess); fclose(fid); mess=['Error reading sqw file type and dimensions - ',mess]; return; end
    if sqw_type
        [mess,main_header]=get_sqw_main_header(fid);
        if ~isempty(mess); fclose(fid); mess=['Error reading number of contributing data sets - ',mess]; return; end
        nfiles=main_header.nfiles;
    else
        nfiles=0;
    end
    fclose(fid);
else
    % Assume prototype sqw file format until fails
    fclose(fid);    % close file again to restart read process in get_sqw
    [mess,main_header,header,detpar,data,position,npixtot,data_type] = get_sqw (infile, '-h');
    if ~isempty(mess); mess=['Error trying to read file as old format Horace .sqw file - ',mess]; return; end
    if ~strcmpi(data_type,'a'); mess='Error trying to read file as old format Horace .sqw file'; return; end
    sqw_type=true;
    ndims=numel(data.pax);
    nfiles=main_header.nfiles;
end
