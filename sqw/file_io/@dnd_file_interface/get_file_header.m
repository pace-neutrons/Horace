function [header,fid] = get_file_header(file,varargin)
% open existing file for rw acces and get sqw file header,
% allowing loaders to identify the type of the file format
% stored within the file
%
%
% $Revision: 1302 $ ($Date: 2016-10-26 18:31:29 +0100 (Wed, 26 Oct 2016) $)
%
%
[header,fid,message] = get_header_(file,varargin{:});
if ~isempty(message)
    if fid>0
        fclose(fid);
    end
    error('DND_FILE_INTERFACE:io_error',['Error: ',message]);
end
% try to interpret input binary stream as horace header and
% convert data stream into structure describing horace format
[header,mess] = get_hor_version_(header);
if ~isempty(mess)
    error('DND_FILE_INTERFACE:runtime_error',['Error: ',message]);
end

