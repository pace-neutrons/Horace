function [mess, main_header] = get_sqw_main_header (fid, fmt_ver, verbatim)
% Read the main header block for the results of performing calculate projections on spe file(s).
%
%   >> [mess, main_header, pos_start] = get_sqw_main_header(fid, fmt_ver)
%
% The default behaviour is that the filename and filepath that are written to file are ignored; 
% we fill with the values corresponding to the file that is actually being read.
% The name written in the file is read if use the '-hverbatim' option (below). This is needed if
% want to alter header information by overwriting with a block of exactly the same length.
%
% Input:
% ------
%   fid             File pointer to (already open) binary file
%   fmt_ver         Version of file format e.g. appversion('-v3')
%   verbatim        Read file name as verbatim
%                       = true  read the stored data file name
%                       = false return the data file name as the file being read
% Output:
% -------
%   mess            Error message; blank if no errors, non-blank otherwise
%   main_header     Structure containing fields read from file (details below)
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
% $Revision$ ($Date$)


mess='';

ver3p1=appversion(3.1);

% Read data from file:
try
    filename = read_sqw_var_char (fid, fmt_ver);
    filepath = read_sqw_var_char (fid, fmt_ver);
    if verbatim
        % Set filename and path from file contents
        main_header.filename=filename;
        main_header.filepath=filepath;
    else
        % Set file name and path from file name (incl. final separator)
        [path,name,ext]=fileparts(fopen(fid));
        main_header.filename=[name,ext];
        main_header.filepath=[path,filesep];
    end
    
    main_header.title = read_sqw_var_char (fid, fmt_ver);

    if fmt_ver>=ver3p1
        main_header.nfiles = fread(fid,1,'float64');
    else
        main_header.nfiles = fread(fid,1,'int32');
    end

catch
    mess='Error reading main header block from file';
    main_header=struct([]);
    
end
