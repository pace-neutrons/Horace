function [header,fid] = get_file_header(file,varargin)
% Open existing file for rw access and get sqw file header,
% allowing loaders to identify the type of the file format
% stored within the file.
% Inputs:
% file       -- the name of the file to read header from
% Optional:
% max_buffer_size 
%            -- the number which defines the maximal 
%                    size  (in bytes) of the file header.
% '-update'  -- if provided, request the file to be opened in read-write 
%               mode allowing subsequent write operations
%               
% Retutns 
% header     -- the structure, describing Horace sqw file header
% fid        -- opened for read or read/write operations file header
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


isnum = cellfun(@(x)isnumeric(x),varargin);
if any(isnum)
    max_buffer_size = varargin{isnum};
    argi = varargin(~isnum);
else
    max_buffer_size = horace_binfile_interface.max_header_size_;    
    argi = varargin;
end
[header,fid,message] = read_header_(file,max_buffer_size,argi{:});
if ~isempty(message)||fid<=0
    if fid>0
        fclose(fid);
    end
    error('HORACE:horace_binfile_interface:io_error','file: %s\n Error: %s', ...
        file,message);
end
% try to interpret input binary stream as Horace header and
% convert data stream into structure describing Horace format
ver_struc = horace_binfile_interface.app_header_form_;
[header,mess] = extract_hor_version_(ver_struc,header);
if ~isempty(mess)
    if fid>0
        fclose(fid);
    end
    error('HORACE:horace_binfile_interface:runtime_error','File: %s  %s', ...
        file,mess);
end


