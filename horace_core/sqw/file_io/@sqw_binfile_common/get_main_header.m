function   main_head = get_main_header(obj,varargin)
% Read the main header block for the results of performing calculate projections on spe file(s).
%
%   >> main_header = obj.get_main_header();
%   >> main_header = obj.get_main_header('-keep_original');
%
% The default behaviour is that the filename and file-path that are written to file are ignored;
% we fill with the values corresponding to the file that is actually being read.
% The name written in the file is read if use the '-hverbatim' option (below). This is needed if
% want to alter header information by overwriting with a block of exactly the same length.
%
% Input:
% ------
%   opt             [Optional] read flag:
%                   '-keep_original'  Do not override file name, stored in
%                   sqw file with current filename (necessary for file
%                   format upgrade)
% Output:
% -------
%   mess            Error message; blank if no errors, non-blank otherwise
%   main_header     Structure containing fields read from file (details below)
%   position        Position of start of main header block
%
%
% Fields read from file are:
% --------------------------
%   main_header.filename   Name of sqw file that is being read, excluding
%                          path. May be mangled with the data creatrion
%                          date
%   main_header.filepath   Path to sqw file that is being read, including terminating file separator
%   main_header.title      Title of sqw data structure
%   main_header.nfiles     Number of spe files that contribute


% Original author: T.G.Perring
%
% leave argi to ignore outdated keys
[ok,mess,keep_original,argi] = parse_char_options(varargin,...
    {'-keep_original'});
if ~ok
    error('HORACE:sqw_binfile_common:invalid_argument',mess);
end


if ischar(obj.num_contrib_files)
    error('HORACE:sqw_binfile_common:runtime_error',...
        'get_main_sqw_header called on un-initialized loader')
end

sz = obj.header_pos_(1)-obj.main_header_pos_;

try
    do_fseek(obj.file_id_,obj.main_header_pos_,'bof');
catch ME
    exc = MException('HORACE:sqw_binfile_common:runtime_error',...
                     'can not move to the start of the main header');
    throw(exc.addCause(ME))
end

bytes = fread(obj.file_id_,sz,'*uint8');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('HORACE:sqw_binfile_common:runtime_error',...
        'can not read main header, Reason: %s',mess);
end


header_format = obj.get_main_header_form();
main_head = obj.sqw_serializer_.deserialize_bytes(bytes,header_format,1);

if obj.convert_to_double
    main_head = obj.do_convert_to_double(main_head);
end

%
if ~keep_original
    [path, name, ext] = fileparts(fopen(obj.file_id_));
    pos = strfind(main_head.filename_with_cdate,'$');
    if isempty(pos)
        main_head.filename_with_cdate = [name, ext];
    else
        main_head.filename_with_cdate = [name, ext,'$',... %keep data creation date even
            main_head.filename_with_cdate(pos+1:end)];     % if the file name have changed
    end
    main_head.filepath =  [path,filesep];
end
% build appropriate class from the stored structure
main_head = main_header_cl(main_head);
