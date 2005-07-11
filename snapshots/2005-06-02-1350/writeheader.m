function writeheader(data,fout)
% This routine writes the following header structure out to a binary file
% called fout.
%
%       data.title_label: title label
%       data.ei: value of ei
%       data.a: a axis
%       data.a: b axis
%       data.a: c axis
%       data.alpha: alpha
%       data.beta: beta
%       data.gamma: gamma
%       data.u1: viewing axis u1 (Q)
%       data.u2: viewing axis u2 (Q)
%       data.u3: viewing axis u3 (Q)
%       data.u4: viewing axis u4 (this is energy)
%       data.nfiles:

disp('Writing header information ');
fid = fopen(fout,'w');
n=length(data.title_label);
fwrite(fid,n,'int32');
fwrite(fid,data.title_label,'char');
fwrite(fid,data.efixed,'float32');
fwrite(fid,data.a,'float32');
fwrite(fid,data.b,'float32');
fwrite(fid,data.c,'float32');
fwrite(fid,data.alpha,'float32');
fwrite(fid,data.beta,'float32');
fwrite(fid,data.gamma,'float32');
fwrite(fid,data.u1,'float32');
fwrite(fid,data.u2,'float32');
fwrite(fid,data.u3,'float32');
fwrite(fid,data.u4,'float32');
fwrite(fid,data.nfiles,'int32');
fclose(fid);
