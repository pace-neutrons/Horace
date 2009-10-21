function mess = put_sqw_object_type (fid, sqw_type, ndims)
% Write application information data strcuture to file
%
%   >> mess = put_sqw_object_type (sqw_type)
%
% Input:
%   fid             File identifier of output file (opened for binary writing)
%   sqw_type        Type of sqw object: =1 if sqw type; =0 if dnd type
%   ndims           Number of dimensions of sqw object
%
% Output:
%   mess            Message if there was a problem writing; otherwise mess=''

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

mess = '';

% Skip if fid not open
flname=fopen(fid);
if isempty(flname)
    mess = 'No open file with given file identifier. Skipping write routine';
    return
end

% Write to file
tmp=int32(logical(sqw_type));
fwrite(fid,tmp,'int32');
fwrite(fid,ndims,'int32');
