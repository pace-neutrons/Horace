function writegrid(data,fout),

% This routine writes the following data structure out to a binary file
% called fout.
%
% data:
%        Data from which a reduced dimensional manifold is to be taken. Its fields are:
% header:
%   data.grid: type of binary file (4D grid, blocks of spe file, etc)
%   data.title: title label
%   data.efixed: value of ei
%   data.a: a axis
%   data.b: b axis
%   data.c c axis
%   data.alpha: alpha
%   data.beta: beta
%   data.gamma: gamma
%   data.file  File from which (h,k,l,e) data was read
%   data.title Title contained in the file from which (h,k,l,e) data was read
%   data.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen  Length of vectors in Ang^-1, energy
%   data.label Labels of theprojection axes (1x4 cell array of charater strings)
%   data.p0    Offset of origin of projection [ph; pk; pl; pen]
%   data.pax   Index of plot axes in the matrix din.u
%               e.g. if data is 3D, din.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, din.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
% if dimension<3D
%   data.iax   Index of integration axes in the matrix din.u
%               e.g. if data is 2D, din.iax=[3,1] means summation has been performed along u3 and u1 axes
%   data.uint  Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]
% block data:
%   data.p1    (Row) vector of bin boundaries along first plot axis
%   data.p2    (Row) vector of bin boundaries along second plot axis
%     :       (for as many plot axes as given by length of din.pax)
%   data.s     Cumulative signal.  [size(din.s)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   data.e     Cumulative variance [size(din.e)=(length(din.p1)-1, length(din.p2)-1, ...)]
%   data.n     Number of contributing pixels [size(din.n)=(length(din.p1)-1, length(din.p2)-1, ...)]

% Author:
%   J. van Duijn     12/06/2005
% Modified:
%
% Horace v0.1   J.Van Duijn, T.G.Perring

writeheader(data,fout);
disp('Writing binary file ...')
fid = fopen(fout,'r+');
fseek(fid, 0, 'eof');
if length(data.pax)==4, % 4D grid
    np1=length(data.p1); % length of vector data.p1
    fwrite(fid,np1,'int32');
    np2=length(data.p2); % length of vector data.p2
    fwrite(fid,np2,'int32');
    np3=length(data.p3); % length of vector data.p3
    fwrite(fid,np3,'int32');
    np4=length(data.p4); % length of vector data.p4
    fwrite(fid,np4,'int32');
    fwrite(fid,data.p1,'float32');
    fwrite(fid,data.p2,'float32');
    fwrite(fid,data.p3,'float32');
    fwrite(fid,data.p4,'float32');
elseif length(data.pax)==3, %3D grid
    np1=length(data.p1); % length of vector data.p1
    fwrite(fid,np1,'int32');
    np2=length(data.p2); % length of vector data.p2
    fwrite(fid,np2,'int32');
    np3=length(data.p3); % length of vector data.p3
    fwrite(fid,np3,'int32');
    fwrite(fid,data.p1,'float32');
    fwrite(fid,data.p2,'float32');
    fwrite(fid,data.p3,'float32');
elseif length(data.pax)==2, %2D grid
    np1=length(data.p1); % length of vector data.p1
    fwrite(fid,np1,'int32');
    np2=length(data.p2); % length of vector data.p2
    fwrite(fid,np2,'int32');
    fwrite(fid,data.p1,'float32');
    fwrite(fid,data.p2,'float32');
elseif length(data.pax)==2, %1D grid
    np1=length(data.p1); % length of vector data.p1
    fwrite(fid,np1,'int32');
    fwrite(fid,data.p1,'float32');
else
    disp(['ERROR! Wrong type of data structure']);
end
fwrite(fid,data.s,'float32');
fwrite(fid,data.e,'float32');
fwrite(fid,data.n,'int16');
fclose(fid);