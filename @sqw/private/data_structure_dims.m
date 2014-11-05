function [nd,sz,szarr] = data_structure_dims(w)
% Find number of dimensions and extent along each dimension of the signal arrays.
%
%   >> [nd,sz,szarr] = data_structure_dims(w)
%
% Input:
% ------
%   w       sqw object (sqw-type or dnd-type) or data structure.
%          Must have either the standard sqw format i.e. four fields named:
%               main_header, header, detpar, data
%
%          or one of the flat format buffer structures: i.e. with fields
%               non-sparse: npix, pix
%               sparse:     sz, nfiles, ndet, ne_max, npix, npix_nz, pix_nz, pix
%                          (sz      = Size of npix array when in non-sparse format
%                           nfiles  = 1 (single spe file) NaN (more than one)
%                           ndet    = no. detectors
%                           ne_max  = max. no. en bins in the spe files)
%
% Output:
% -------
%   nd      Dimensionality of the sqw or dnd data (=NaN if a buffer type)
%   sz      Number of bins along each dimension (=NaN if a buffer type):
%               - If 0D sqw object, nd=[], sz=zeros(1,0)
%               - if 1D sqw object, nd=1,  sz=n1
%               - If 2D sqw object, nd=2,  sz=[n1,n2]
%               - If 3D sqw object, nd=3,  sz=[n1,n2,n3]     even if n3=1
%               - If 4D sqw object, nd=4,  sz=[n1,n2,n3,n4]  even if n4=1
%   szarr   Size of signal array as returned by Matlab size function
%
%
% NOTE: This is not a robust routine - it assumes that the data structure
%       actually has one of the following formats:
%
%               ='h'         header part of w.data only is required
%                           i.e. fields filename,...,uoffset,...,dax
%                           [The fields main_header, header, detpar
%                           must exist but can be empty - they are ignored]
%
%               ='dnd'       dnd object or dnd structure
%               ='dnd_sp'    dnd structure, sparse format
%
%               ='sqw'       sqw object or sqw structure
%               ='sqw_sp'    sqw structure, sparse format
%
%               ='sqw_'      sqw structure without pix array
%               ='sqw_sp_'   sqw structure, sparse format, without
%                           npix_nz,pix_nz,pix arrays
%
%               ='buffer'    sqw structure, only w.data.npix, w.data.pix required
%                           [The fields main_header, header, detpar
%                           must exist but can be empty - they are ignored]
%                       *OR* Flat structure with only npix, pix required
%
%               ='buffer_sp' sqw structure, required fields:
%                               w.header: en
%                               w.detpar: <all fields>
%                               w.data: p, npix, npix_nz, pix_nz, pix are required
%                       *OR* Flat structure with fields:
%                               sz, nfiles, ndet, ne_max, npix, npix_nz, pix_nz, pix
%
%       Only uses the header part of the data field if it can, so that only
%       the header of valid sqw-type or dnd-type data needs to be passed.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


[data_type_name,sparse_fmt,flat] = data_structure_type_name(w);
data_type = data_structure_name_to_type(data_type_name);

if ~data_type.buffer_data
    [nd,sz,szarr]=get_dims_internal(w.data);
    
else
    nd=NaN;
    sz=NaN;
    if flat
        if sparse_fmt
            szarr=w.sz;
        else
            szarr=size(w.npix);
        end
    else
        if sparse_fmt
            [~,~,szarr]=get_dims_internal(w.data);
        else
            szarr=size(w.data.npix);
        end
    end
end

%------------------------------------------------------------------------------
function [nd,sz,szarr]=get_dims_internal(data)
nd=numel(data.pax);
sz=zeros(1,nd);
for i=1:nd
    sz(i)=length(data.p{i})-1;
end
if nd==0
    szarr=[1,1];
elseif nd==1
    szarr=[sz,1];
else
    szarr=sz;
end
