function [header,fid] = get_file_header(file,varargin)
% Open existing file for rw access and get sqw file header,
% allowing loaders to identify the type of the file format
% stored within the file.
%
% The header is the structure with the fields:
% 'version'  -- version of the application
% 'name'     -- the application name, expected "horace" for Horace headers
% 'typestart'-- auxiliary number defining byte position of sqw type in
%               array of bytes (18 for modern Horace files, 0 for pre-release)
% 'uncertain' -- if true, the header is not identified with certainty and further
%                analysis of file contents is necessary to be sure that the file is Horace file
%                It is true when legacy Horace version is encountered. Legacy file loaders
%                performs additional analysis to verify if the provided file is Horace file
%                or just binary file with initial bytes which look like a header Horace. 
%
% 'sqw_type'  -- if sqw file is sqw or dnd file
% 'num_dim'   -- number of dimensions in sqw or dnd file
%
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
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

