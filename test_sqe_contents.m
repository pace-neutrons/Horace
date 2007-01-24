function messlen=test_sqe_contents(binfil)

% Read header information from sqe file:
% ---------------------------------------
fid= fopen(binfil, 'r');    % open sqe file
if fid<0; error (['ERROR: Unable to open file ',binfil]); end
[h,mess] = get_header(fid);   % get the main header information
h

% Read data from the blocks
% --------------------------
plims=[0,0.1;0,0.1;0.0,0.1;0.0,0.1];
messlen=0;
for ifile=1:h.nfiles
    [data, mess, lis, info] = get_sqe_datablock (fid, plims);
    messlen=messlen+length(mess);
end
fclose(fid);
