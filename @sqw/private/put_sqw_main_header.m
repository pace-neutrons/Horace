function [mess,position] = put_sqw_main_header (fid, fmt_ver, main_header)
% Write the main header block for the results of performing calculate projections on spe file(s).
%
%   >> [mess,position] = put_sqw_main_header (fid, fmt_ver, main_header)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   fmt_ver         Version of file format e.g. appversion('-v3')
%   main_header     Data structure which must contain (at least) the fields listed below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Position of start of main header block
%
%
% Fields written to file are:
% ---------------------------
%   main_header.filename    Name of file that was the source of sqw data structure, excluding path
%   main_header.filepath    Path to file including terminating file separator
%   main_header.title       Title of sqw data structure
%   main_header.nfiles      Number of spe files that contribute
%
%
% Notes:
% ------
% There are some other items written to the file to help when reading the file using get_sqw_data.
% These are indicated by comments in the code.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
position = ftell(fid);

ver3p1=appversion(3.1);

try
    write_sqw_var_char (fid, fmt_ver, main_header.filename);
    write_sqw_var_char (fid, fmt_ver, main_header.filepath);
    write_sqw_var_char (fid, fmt_ver, main_header.title);
    if fmt_ver>=ver3p1
        fwrite(fid,main_header.nfiles);
    else
        fwrite(fid,main_header.nfiles,'int32');
    end
    
catch
    mess='Error writing main header block to file';
end
