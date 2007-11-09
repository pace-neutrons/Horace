function mess = write_sqw_main_header (fid, data)
% Write the main header block for the results of performing calculate projections on spe file(s).
%
%   >> mess = write_sqw_header (fid, data)
%
% Input:
%   fid             File identifier of output file (opened for binary writing)
%   data            Data structure which must contain (at least) the fields listed below
%
% Output:
%   mess            Message if there was a problem writing; otherwise mess=''
%
%
% Fields written to file are:
%   data.filename   Name of file that was the source of sqw data structure, excluding path
%   data.filepath   Path to file including terminating file separator
%   data.title      Title of sqw data structure
%   data.nfiles     Number of spe files that contribute
%
%
% Notes:
% ------
%   There are some other items written to the file to help when reading the file using get_sqw_data. 
% These are indicated by comments in the code.

% T.G.Perring 28/6/07

mess = '';

% Skip if fid not open
flname=fopen(fid);
if isempty(flname)
    mess = 'No open file with given file identifier. Skipping write routine';
    return
end

% Write to file

n=length(data.filename);
fwrite(fid,n,'int32');              % write length of filename
fwrite(fid,data.filename,'char');

n=length(data.filepath);
fwrite(fid,n,'int32');              % write length of filepath
fwrite(fid,data.filepath,'char');

n=length(data.title);
fwrite(fid,n,'int32');              % write length of title
fwrite(fid,data.title,'char');

fwrite(fid,data.nfiles,'int32');
