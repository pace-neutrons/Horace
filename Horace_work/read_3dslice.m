function d= read_3dslice(fin)

% this routine reads the binary file created using write_3dslice into a
% matlab workspace
%
% output:
%   d.stype: type of 3D grid, 'QQE' or 'QQQ'
%   d.file: binary file name
%   d.title: title of the binary file
%   d.u_to_rlu: Vectors u1, u2, u3 in reciprocal lattice vectors: 
%   d.ulen: Row vector of lengths of ui in Ang^-1
%   d.p0: Vector defining origin of the plane in Q-space (r.l.u.)
%   d.u1: vector of u1 bin boundary values 
%   d.u2: vector of u2 bin boundary values
%   d.u3: vector of u3 bin boundary values
%   d.int(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1): cummulative
%   intensity array float32
%   d.err(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1): cummulative error
%   array float32
%   d.nint(length(d.u1)-1,length(d.u2)-1, length(d.u3)-1): Number of pixels
%   that contributed to a bin is given by nint int16

% Author:
%   J. van Duijn     10/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

fid= fopen(fin, 'r');
[n,count]= fread(fid, 1, 'int32');
[d.stype,count]= fread(fid, [1 n], '*char');
[n,count]= fread(fid, 1, 'int32');
[d.file,count]= fread(fid, [1 n], '*char');
[n,count]= fread(fid, 1, 'int32');
[d.title,count]= fread(fid, [1 n], '*char');
[d.u_to_rlu,count]= fread(fid, [3 3], 'float32');
[d.ulen,count]= fread(fid, [1 3], 'float32');
[d.p0,count]= fread(fid, [1 3], 'float32');
[sa, count]= fread(fid, [1, 3], 'int32');
[d.u1,count]= fread(fid, [1,sa(1)], 'float32');
[d.u2,count]= fread(fid, [1,sa(2)], 'float32');
[d.u3,count]= fread(fid, [1,sa(3)], 'float32');
[d.int,count]= fread(fid, [(sa(1)-1)*(sa(2)-1) sa(3)-1], 'float32');
d.int=reshape(d.int, sa(1)-1, sa(2)-1, sa(3)-1);
[d.err,count]= fread(fid, [(sa(1)-1)*(sa(2)-1) sa(3)-1], 'float32');
d.err=reshape(d.err, sa(1)-1, sa(2)-1, sa(3)-1);
[d.nint,count]= fread(fid, [(sa(1)-1)*(sa(2)-1) sa(3)-1], 'int16');
d.nint=int16(reshape(d.nint, sa(1)-1, sa(2)-1, sa(3)-1));
fclose(fid);