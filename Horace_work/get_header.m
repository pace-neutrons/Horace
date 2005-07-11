function data = get_header(fid)
% Reads a header structure out from either a binary .spe file or a binary orthogonal grid file.
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%
% Output:
% -------
% Fields read for both 'spe' or 'orthogonal-grid' data:
%
%   data.file   File from which (h,k,l,e) data was read [Character string]
%   data.grid   Type of grid ('spe' or 'orthogonal-grid') [Character string]
%   data.title  Title contained in the file from which (h,k,l,e) data was read [Character string]
%   data.a      Lattice parameters (Angstroms)
%   data.b           "
%   data.c           "
%   data.alpha  Lattice angles (degrees)
%   data.beta        "
%   data.gamma       "
%   data.u      Matrix (4x4) of projection axes in original 4D representation
%               u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen   Length of vectors in Ang^-1 or meV [row vector]
%   data.label  Labels of the projection axes [1x4 cell array of charater strings]
%
% If a 1D,2D,3D, or 4D data structure, then in addition read :
%
%   data.p0     Offset of origin of projection [ph; pk; pl; pen] [column vector]
%   data.pax    Index of plot axes in the matrix data.u  [row vector]
%               e.g. if data is 3D, data.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   data.iax    Index of integration axes in the matrix data.u
%               e.g. if data is 2D, data.iax=[3,1] means summation has been performed along u3 and u1 axes
%   data.uint   Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]


% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

disp('Reading header information ...');

[n,count]= fread(fid,1,'int32');
[data.grid,count]= fread(fid,[1,n],'*char');

[n,count]= fread(fid,1,'int32');
[data.title,count]= fread(fid,[1,n],'*char');

[data.a,count] = fread(fid,1,'float32');
[data.b,count] = fread(fid,1,'float32');
[data.c,count] = fread(fid,1,'float32');
[data.alpha,count] = fread(fid,1,'float32');
[data.beta,count] = fread(fid,1,'float32');
[data.gamma,count] = fread(fid,1,'float32');
[data.u,count] = fread(fid,[4,4],'float32');
[data.ulen,count] = fread(fid,[1,4],'float32');

if strcmp(data.grid,'spe'),
    [data.nfiles,count] = fread(fid,1,'int32');
    % p0, pax, iax and uint undefined (data needs to be sliced first)
else
    [n,count]= fread(fid,2,'int32');
    [label,count]=fread(fid,[n(1),n(2)],'*char');
    data.label=cellstr(label)';
    
    [data.p0,count]= fread(fid,[4,1],'int32');
    [n,count]= fread(fid,1,'int32');
    [data.pax,count]=fread(fid,[1,n],'int32');
    if n==4,
        data.iax=[]; % create empty index of integration array
        data.uint=[];
    else
        [n,count]= fread(fid,1,'int32');
        [data.iax,count]=fread(fid,[1,n],'int32');
        [data.uint,count]=fread(fid,[2,n],'float32');
    end
end