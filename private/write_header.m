function write_header (fid, data)
% Writes a header structure to a binary file that will hold .spe data or
% orthogonal grid data.
%
% Syntax:
%   >> write_header (fid, data)
%
% Input:
% ------
%   fid     File pointer to (already open) binary file
%
%   data    Data structure with header information:
%
% Fields written for both 'spe' or 'orthogonal-grid' data:
%
%   data.grid   Type of grid ('spe', 'sqe' or 'orthogonal-grid') [Character string]
%   data.title  Title contained in the file from which (h,k,l,e) data was read [Character string]
%   data.a      Lattice parameters (Angstroms)
%   data.b           "
%   data.c           "
%   data.alpha  Lattice angles (degrees)
%   data.beta        "
%   data.gamma       "
%   data.u      Matrix (4x4) of projection axes in original 4D representation
%                   u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen   Length of vectors in Ang^-1 or meV [row vector]
%   data.label  Labels of the projection axes [1x4 cell array of charater strings]
%
% If writing a binary spe file or binary sqe file:
%   data.nfiles Number of spe files in the binary file
%   data.urange Range along each of the axes: [u1_lo, u2_lo, u3_lo, u4_lo; u1_hi, u2_hi, u3_hi, u4_hi]
%   data.ebin   Energy bin width of first, minimum and maxiumum values: [ebin_first, ebin_min, ebin_max]
%   data.en0    Energy bin centres for the first spe file
%
% If a 0D,1D,2D,3D, or 4D data structure:
%
%   data.p0     Offset of origin of projection [ph; pk; pl; pen] [column vector]
%   data.pax    Index of plot axes in the matrix data.u  [row vector]
%                   e.g. if data is 3D, data.pax=[2,4,1] means u2, u4, u1 axes are x,y,z in any plotting
%                                2D, data.pax=[2,4]     "   u2, u4,    axes are x,y   in any plotting
%   data.iax    Index of integration axes in the matrix data.u
%               e.g. if data is 2D, data.iax=[3,1] means summation has been performed along u3 and u1 axes
%   data.uint   Integration range along each of the integration axes. Dimensions are uint(2,length(iax))
%               e.g. in 2D case above, is the matrix vector [u3_lo, u1_lo; u3_hi, u1_hi]

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

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
label=char(data.label);
n=size(label);
fwrite(fid,n,'int32');
fwrite(fid,label,'char'); 

if strcmp(data.grid,'spe')|strcmp(data.grid,'sqe'),
    fwrite(fid,data.nfiles,'int32');
    fwrite(fid, data.urange, 'float32');
    fwrite(fid, data.ebin, 'float32');
    ne = length(data.en0);
    fwrite(fid, ne, 'int32');
    fwrite(fid, data.en0, 'float32');
else  
    fwrite(fid,data.p0,'float32');
    fwrite(fid,length(data.pax),'int32');
    if ~isempty(data.pax)
        fwrite(fid,data.pax,'int32');
    end
    if ~isempty(data.iax),
        fwrite(fid,length(data.iax),'int32');
        fwrite(fid,data.iax,'int32');
        fwrite(fid,data.uint,'float32');
    end
end
