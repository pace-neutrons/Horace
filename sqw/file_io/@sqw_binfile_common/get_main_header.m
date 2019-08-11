function   main_header = get_main_header(obj,varargin)
% Read the main header block for the results of performing calculate projections on spe file(s).
%
%   >> main_header = obj.get_main_header();
%   >> main_header = obj.get_main_header('-v');
%
% The default behaviour is that the filename and filepath that are written to file are ignored;
% we fill with the values corresponding to the file that is actually being read.
% The name written in the file is read if use the '-hverbatim' option (below). This is needed if
% want to alter header information by overwriting with a block of exactly the same length.
%
% Input:
% ------
%   opt             [Optional] read flag:
%                   '-verbatim'   The file name as stored in the main_header is returned as stored,
%                                and not constructed from the value of fopen(fid).
% Output:
% -------
%   mess            Error message; blank if no errors, non-blank otherwise
%   main_header     Structure containing fields read from file (details below)
%   position        Position of start of main header block
%
%
% Fields read from file are:
% --------------------------
%   main_header.filename   Name of sqw file that is being read, excluding path
%   main_header.filepath   Path to sqw file that is being read, including terminating file separator
%   main_header.title      Title of sqw data structure
%   main_header.nfiles     Number of spe files that contribute


% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)

if ischar(obj.num_contrib_files)
    error('SQW_FILE_INTERFACE:runtime_error',...
        'get_main_sqw_header called on un-initialized loader')
end

sz = obj.header_pos_(1)-obj.main_header_pos_;

%
fseek(obj.file_id_,obj.main_header_pos_,'bof');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_FILE_INTERFACE:runtime_error',...
        'can not move to the start of the main header, reason: %s',mess);
end
%
bytes = fread(obj.file_id_,sz,'*uint8');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_FILE_INTERFACE:runtime_error',...
        'can not read main header, Reason: %s',mess);
end


header_format = obj.get_main_header_form();
main_header = obj.sqw_serializer_.deserialize_bytes(bytes,header_format,1);

if obj.convert_to_double
    main_header = obj.do_convert_to_double(main_header);
end

%
if nargin>1
    if strncmp(varargin{1},'-v',2) % return file header as it is, not construct
        % it from file name
        return;
    end
end
[path, name, ext] = fileparts(fopen(obj.file_id_));
main_header.filepath =  [path,filesep];
main_header.filename = [name, ext];


