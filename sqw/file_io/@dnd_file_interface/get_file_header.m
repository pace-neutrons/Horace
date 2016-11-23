function [header,fid] = get_file_header(file,varargin)
% open existing file for rw access and get sqw file header,
% allowing loaders to identify the type of the file format
% stored within the file
%
% The header is the structure with the fields:
% 'version'  -- version of the application
% 'name'     -- the application name, expected "Horace" for Horace headers
% 'typestart'-- auxiliary number defining byte position of sqw type in
%               array of bytes (18 for modern Horace files, 0 for pre-release)
% 'uncertain' -- if true, the header is not identified with certainty and further
%                analysis of byte stream is necessary to be sure that the file is Horace file
%                it usually true when legacy Horace version is encountered
%
% 'sqw_type'  -- if sqw file is sqw or dnd file
% 'num_dim'   -- number of dimensions in sqw or dnd file
%
%
% $Revision$ ($Date$)
%
%
[header,fid,message] = read_header_(file,varargin{:});
if ~isempty(message)
    if fid>0
        fclose(fid);
    end
    error('SQW_FILE_IO:io_error','file: %s\n Error: %s',file,message);
end
% try to interpret input binary stream as Horace header and
% convert data stream into structure describing Horace format
[header,mess] = extract_hor_version_(header);
if ~isempty(mess)
    if fid>0
        fclose(fid);
    end
    error('SQW_FILE_IO:runtime_error','Error: %s',message);
end

