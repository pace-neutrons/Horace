function [data, mess] = get_sqw_main_header (fid, data_in)
% Read the main header block for the results of performing calculate projections on spe file(s).
%
% Syntax:
%   >> [data, mess] = get_sqw_main_header(fid, data_in)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   data_in     [optional] Data structure to which the data
%              fields below will be added or overwrite.
%
% Output:
% -------
%   data        Structure containing fields read from file (details below)
%   mess        Error message; blank if no errors, non-blank otherwise
%
% Fields read from file are:
%   data.filename   Name of sqw file that is being read, excluding path
%   data.filepath   Path to sqw file that is being read, including terminating file separator
%   data.title      Title of sqw data structure
%   data.nfiles     Number of spe files that contribute
%
% Note that the filename and filepath that are written to file are ignored; we fill with the 
% values corresponding to the file that is being read.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if nargin==2
    if isstruct(data_in)
        data = data_in;
    else
        mess = 'Check the type of input argument data_in';
        return
    end
else
    data = [];
end

mess='';

% Get file name and path (incl. final separator)
[path,name,ext,ver]=fileparts(fopen(fid));
data.filename=[name,ext,ver];
data.filepath=[path,filesep];

% Read data from file:
try
    n = fread_catch(fid,1,'int32');
    dummy_filename = fread(fid,[1,n],'*char');

    n = fread_catch(fid,1,'int32');
    dummy_filepath = fread(fid,[1,n],'*char');

    n = fread_catch(fid,1,'int32');
    data.title = fread(fid,[1,n],'*char');

    data.nfiles = fread(fid,1,'int32');

catch
    mess='problems reading file';
end
