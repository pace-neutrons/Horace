function write_3dslice(d,fout)

% this routine writes the d structure created using slice_3D out to a
% binary file.
%
% input:
% ------
%   d.stype         Type of 3D grid, 'QQE' or 'QQQ'
%   d.file          File from which (h,k,l,e) data was read
%   d.title         Title of the binary file from which (h,k,l,e) data was read
%   d.u_to_rlu      Vectors u1, u2, u3 (r.l.u.) 
%   d.ulen          Row vector of lengths of ui in Ang^-1
%   d.p0            Vector defining origin of the plane in Q-space (r.l.u.)
%   d.u1            Vector of u1 bin boundary values 
%   d.u2            Vector of u2 bin boundary values
%   d.u3            Vector of u3 bin boundary values
%   d.int(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Cumulative intensity array
%   d.err(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Cumulative intensity array
%   d.nint(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1)
%                   Number of pixels that contributed to a bin [int16]
%
%   fout: output binary file

% Author:
%   J. van Duijn     10/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

fid= fopen(fout, 'w');

n=length(d.stype);
fwrite(fid,n,'int32');
fwrite(fid,d.stype,'char');
n=length(d.file);
fwrite(fid,n,'int32');
fwrite(fid,d.file,'char');
n=length(d.title);
fwrite(fid,n,'int32');
fwrite(fid,d.title,'char');
fwrite(fid,d.u_to_rlu,'float32');
fwrite(fid,d.ulen,'float32');
fwrite(fid,d.p0,'float32');
nu1= length(d.u1); 
nu2= length(d.u2);
nu3= length(d.u3);
fwrite(fid, [nu1 nu2 nu3], 'int32');
fwrite(fid,d.u1,'float32');
fwrite(fid,d.u2,'float32');
fwrite(fid,d.u3,'float32');
d.int=reshape(d.int, (nu1-1)*(nu2-1), nu3-1); % convert to a 2 dimensional array so it can be read in using fread
fwrite(fid,d.int,'float32');
d.err=reshape(d.err, (nu1-1)*(nu2-1), nu3-1);
fwrite(fid,d.err,'float32');
d.nint=reshape(d.nint, (nu1-1)*(nu2-1), nu3-1);
fwrite(fid,d.nint,'int16');
fclose(fid);
