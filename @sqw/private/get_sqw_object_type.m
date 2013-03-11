function [sqw_type, ndims, mess] = get_sqw_object_type (fid)
% Read the type of sqw object written to file
%
%   >> [sqw_type, mess] = get_sqw_object_type (fid)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%
% Output:
% -------
%   sqw_type    Type of sqw object written to file: =1 if sqw type; =0 if dnd type
%   ndims       Number of dimensions of sqw object
%   mess        Error message; blank if no errors, non-blank otherwise


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


sqw_type=[];
ndims=[];
mess='';

% Read data from file:
try
    tmp = fread (fid,1,'int32');
    sqw_type = logical(tmp);
    ndims = fread (fid,1,'int32');
catch
    mess='problems reading data file';
end
