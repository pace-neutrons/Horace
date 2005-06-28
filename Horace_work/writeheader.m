function writeheader(data,fout)
% This routine writes the following header structure out to a binary file
% called fout.
%
%       data.grid: type of binary file (4D grid, blocks of spe file, etc)
%       data.title: title label
%       data.efixed: value of ei
%       data.a: a axis
%       data.b: b axis
%       data.c c axis
%       data.alpha: alpha
%       data.beta: beta
%       data.gamma: gamma
%       data.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%       din.ulen  Length of vectors in Ang^-1, energy
%       data.nfiles: number of spe files contained within the binary file
%   if data is in grid:
%       din.p0    Offset of origin of projection [ph; pk; pl; pen]
%       din.pax   Index of plot axes in the matrix din.u
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes
%                               are x,y   in any plotting


% Author:
%   J. van Duijn    01/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring


disp('Writing header information ');
fid = fopen(fout,'w');
n=length(data.grid);
fwrite(fid,n,'int32');
fwrite(fid,data.grid,'char');
n=length(data.title);
fwrite(fid,n,'int32');
fwrite(fid,data.title,'char');
fwrite(fid,data.ei,'float32');
fwrite(fid,data.a,'float32');
fwrite(fid,data.b,'float32');
fwrite(fid,data.c,'float32');
fwrite(fid,data.alpha,'float32');
fwrite(fid,data.beta,'float32');
fwrite(fid,data.gamma,'float32');
fwrite(fid,data.u,'float32');
fwrite(fid,data.ulen,'float32');
if strcmp(data.grid,'spe'),
    fwrite(fid,data.nfiles,'int32');
    % we don't yet know what p0 and pax will be. Data needs to be sliced
    % first
elseif strcmp(data.grid,'4D');
    fwrite(fid,data.nfiles,'int32');
    label=char(data.label);
    n=size(label);
    fwrite(fid,n,'int32');
    fwrite(fid,label, 'char');
    fwrite(fid,data.p0,'float32');
    fwrite(fid,length(data.pax),'int32');
    fwrite(fid,data.pax,'int32');
else
    label=char(data.label);
    n=size(label);
    fwrite(fid,n,'int32');
    fwrite(fid,label, 'char');
    fwrite(fid,data.p0,'float32');
    fwrite(fid,length(data.pax),'int32');
    fwrite(fid,data.pax,'int32');
    fwrite(fid,length(data.iax),'int32');
    fwrite(fid,data.iax,'int32');
    fwrite(fid,data.uint,'float32');
end
fclose(fid);
