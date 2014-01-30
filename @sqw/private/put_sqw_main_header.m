function [mess,position] = put_sqw_main_header (fid, main_header)
% Write the main header block for the results of performing calculate projections on spe file(s).
%
%   >> [mess,position] = put_sqw_main_header (fid, main_header)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
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

try
    n=length(main_header.filename);
    fwrite(fid,n,'int32');              % write length of filename
    fwrite(fid,main_header.filename,'char');
    
    n=length(main_header.filepath);
    fwrite(fid,n,'int32');              % write length of filepath
    fwrite(fid,main_header.filepath,'char');
    
    n=length(main_header.title);
    fwrite(fid,n,'int32');              % write length of title
    fwrite(fid,main_header.title,'char');
    
    fwrite(fid,main_header.nfiles,'int32');
    
catch
    mess='Error writing main header block to file';
end
