function [header,fid] = get_file_header(file,varargin)
% open existing file for rw acces and get sqw file header,
% allowing loaders to identify the type of the file format
% stored within the file
%
%
% $Revision$ ($Date$)
%
%
[header,fid,message] = get_header_(file,varargin{:});
if ~isempty(message)
    if fid>0
        fclose(fid);
    end
    error('DND_FILE_INTERFACE:io_error','Error: %s',message);
end
% try to interpret input binary stream as horace header and
% convert data stream into structure describing horace format
[header,mess] = get_hor_version_(header);
if ~isempty(mess)
    if fid>0
        fclose(fid);
    end    
    error('DND_FILE_INTERFACE:runtime_error','Error: %s',message);
end

