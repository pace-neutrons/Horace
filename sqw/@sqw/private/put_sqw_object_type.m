function [mess, position] = put_sqw_object_type (fid, sqw_type, ndims)
% Write application information data structure to file
%
%   >> [mess, position] = put_sqw_object_type (fid, sqw_type, ndims)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   sqw_type        Type of sqw object: =1 if sqw type; =0 if dnd type
%   ndims           Number of dimensions of sqw object
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Position of the start of the sqw object type block


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
position = ftell(fid);

try
    tmp=int32(logical(sqw_type));
    fwrite(fid,tmp,'int32');
    fwrite(fid,ndims,'int32');
catch
    mess='Error writing sqw type and dimensions block to file';
end
