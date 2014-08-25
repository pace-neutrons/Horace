function [mess, position] = put_sqw_LEGACY_object_type (fid, fmt_ver, sqw_type, ndims)
% Write application information data structure to file
%
%   >> [mess, position] = put_sqw_LEGACY_object_type (fid, sqw_type, ndims)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   fmt_ver         Version of file format e.g. appversion('-v3')
%   sqw_type        Type of sqw object: =1 if sqw type; =0 if dnd type
%   ndims           Number of dimensions of sqw object
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Position of the start of the sqw object type block


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

mess = '';
position = ftell(fid);

try
    tmp=int32(logical(sqw_type));
    fwrite(fid,tmp,'int32');
    fwrite(fid,ndims,'int32');
catch
    mess='Error writing sqw type and dimensions block to file';
end


% mess = '';
% position = ftell(fid);
% 
% ver3p1=appversion(3.1);
% 
% try
%     write_sqw_var_logical_scalar(fid, fmt_ver, sqw_type)
%     if fmt_ver>=ver3p1
%         fwrite(fid, ndims, 'float64');
%     else
%         fwrite(fid, ndims, 'int32');
%     end
% catch
%     mess='Error writing sqw type and dimensions block to file';
% end
