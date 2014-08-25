function [mess, sqw_type, ndims, position] = get_sqw_object_type (fid, fmt_ver)
% Read the type of sqw object written to file
%
%   >> [mess, sqw_type, ndims, position] = get_sqw_object_type (fid, fmt_ver)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
% Output:
% -------
%   mess        Error message; blank if no errors, non-blank otherwise
%   sqw_type    Type of sqw object written to file: =1 if sqw type; =0 if dnd type
%   ndims       Number of dimensions of sqw object
%   position    Position of the start of the sqw object type block


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


mess='';
sqw_type=[];
ndims=[];
position = ftell(fid);

ver3p1=appversion(3.1);

try
    sqw_type = read_sqw_var_logical_scalar (fid, fmt_ver);
    if fmt_ver>=ver3p1
        ndims = fread (fid,1,'float64');
    else
        ndims = fread (fid,1,'int32');
    end
catch
    mess='Error reading sqw type and dimensions block from file';
end
