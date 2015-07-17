function [mess, position_info_location, data_type, position] = get_sqw_file_footer (fid)
% Read final entry to sqw file: location of position information in the file and data_type
%
%   >> [mess, position_info_location, data_type, position] = get_sqw_file_footer (fid)
%
% It is assumed that on entry that the pointer is just after the end of this block,
% which should in fact be the end of the file.
%
% Input:
% ------
%   fid                     File pointer to (already open) binary file
%
% Output:
% -------
%   mess                    Message if there was a problem writing; otherwise mess=''
%   position_info_location  Position of the position information block
%   data_type               Type of sqw data contained in the file: will be one of
%                               type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                               type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                               type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%                               type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%   position                Position of the file footer in the file

position_info_location=[];
data_type='';
position = ftell(fid);

% Read data from file:
try
    fseek(fid,-4,'cof');        % we assume that we are at the end of the block of data
    [n, count, ok, mess] = fread_catch(fid,1,'int32'); if ~all(ok); return; end;
    fseek(fid,-(n+12),'cof');   % move to start of the block of data (8-byte position + n-byte string + 4-byte string length)
    [position_info_location, count, ok, mess] = fread_catch(fid,1,'float64'); if ~all(ok); return; end;
    [data_type, count, ok, mess] = fread_catch(fid,[1,n],'*char*1'); if ~all(ok); return; end;
catch
    mess='Error reading footer block from file';
end
