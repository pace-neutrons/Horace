function [mess, sqw_type, ndims, position] = get_object_type (fid)
% Read the type of sqw object written to file
%
%   >> [mess, sqw_type, ndims, position] = get_sqw_object_type (fid)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%
% Output:
% -------
%   mess        Error message; blank if no errors, non-blank otherwise
%   sqw_type    Type of sqw object written to file: =1 if sqw type; =0 if dnd type
%   ndims       Number of dimensions of sqw object
%   position    Position of the start of the sqw object type block


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)


mess='';
sqw_type=[];
ndims=[];
position = ftell(fid);

try
    tmp = fread (fid,1,'int32');
    sqw_type = logical(tmp);
    ndims = fread (fid,1,'int32');
catch
    mess='Error reading sqw type and dimensions block from file';
end
