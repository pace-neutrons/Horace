function write_header (fid, data)
% Writes a header structure to a binary file that will hold .spe data ot
% orthogonal grid data.
%
% Input:
% ------
%   fid     File pointer to (already open) binary file
%
%   data    Data structure with header information:
%
% Fields written for both 'spe' or 'orthogonal-grid' data:
%
%   data.file  File from which (h,k,l,e) data was read [Character string]
%   data.grid  Type of grid ('spe' or 'orthogonal-grid') [Character string]
%   data.title Title contained in the file from which (h,k,l,e) data was read [Character string]
%   data.a     Lattice parameters (Angstroms)
%   data.b           "
%   data.c           "
%   data.alpha Lattice angles (degrees)
%   data.beta        "
%   data.gamma       "
%   data.u     Matrix (4x4) of projection axes in original 4D representation
%              u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen  Length of vectors in Ang^-1 or meV [row vector]
%   data.label Labels of the projection axes [1x4 cell array of charater strings]
%
% If a 1D,2D,3D, or 4D data structure, then in addition write :
%
%   data.p0    Offset of origin of projection [ph; pk; pl; pen] [column vector]
%   data.pax   Index of plot axes in the matrix data.u  [row vector]
%               e.g. if data is 3D, data.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                               2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   data.iax   Index of integration axes in the matrix data.u
%               e.g. if data is 2D, data.iax=[3,1] means summation has been performed along u3 and u1 axes
%   data.uint  Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]


% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


disp('Writing header information ');

n=length(data.grid);
fwrite(fid,n,'int32');
fwrite(fid,data.grid,'char');

n=length(data.title);
fwrite(fid,n,'int32');
fwrite(fid,data.title,'char');

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
    % p0, pax, iax and uint undefined (data needs to be sliced first)
else
    label=char(data.label)
    n=size(label);
    fwrite(fid,n,'int32');
    fwrite(fid,label,'char');
    
    fwrite(fid,data.p0,'float32');
    fwrite(fid,length(data.pax),'int32');
    fwrite(fid,data.pax,'int32');
    if ~isempty(data.iax),
        fwrite(fid,length(data.iax),'int32');
        fwrite(fid,data.iax,'int32');
        fwrite(fid,data.uint,'float32');
    end
end
