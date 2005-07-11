function appendheader(nfiles, binfil)
%
% appends the number of spe files contained in the bin file

% Author:
%   J. van Duijn     01/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

disp('appending header information ...')
fid = fopen(binfil,'r+');
[n,count]= fread(fid,1,'int32');
[data.title,count]= fread(fid,n,'*char');
data.title= data.title';
[data.ei,count] = fread(fid,1,'float32');
[data.a,count] = fread(fid,1,'float32');
[data.b,count] = fread(fid,1,'float32');
[data.c,count] = fread(fid,1,'float32');
[data.alpha,count] = fread(fid,1,'float32');
[data.beta,count] = fread(fid,1,'float32');
[data.gamma,count] = fread(fid,1,'float32');
[data.u1,count] = fread(fid,4,'float32');
[data.u2,count] = fread(fid,4,'float32');
[data.u3,count] = fread(fid,4,'float32');
[data.u4,count] = fread(fid,4,'float32');
fseek(fid, 0, 'cof');
fwrite(fid,nfiles,'int32');
fclose(fid);