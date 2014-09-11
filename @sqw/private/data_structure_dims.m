function [nd,sz,szarr] = data_structure_dims(w)
% Find number of dimensions and extent along each dimension of the signal arrays.
%
%   >> [nd,sz,szarr] = data_structure_dims(w)
%
% Input:
% ------
%   w       sqw object (sqw-type or dnd-type) or data structure.
%          Must have either the standard sqw format
%                  i.e. four fields named:
%                       main_header, header, detpar, data
%
%                  or one of the flat format buffer structures:
%                       non-sparse: npix, pix
%                       sparse:     ndet, ne, npix, npix_nz, pix_nz, pix
%                                  (ndet=no. detectors; ne=column vector of
%                                   number of energy bins in each spe file)
%
% Output:
% -------
%   nd      Dimensionality of the sqw or dnd data
%   sz      Number of bins along each dimension:
%               - If 0D sqw object, nd=[], sz=zeros(1,0)
%               - if 1D sqw object, nd=1,  sz=n1
%               - If 2D sqw object, nd=2,  sz=[n1,n2]
%               - If 3D sqw object, nd=2,  sz=[n1,n2,n3]   even if n3=1
%               - If 4D sqw object, nd=2,  sz=[n1,n2,n3,n4]  even if n4=1
%   szarr   Size of signal array as returned by Matlab size function

% Only uses the header part of the data field if it can


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


if isa(w,'sqw') || isfield(w,'data')    % catch case of object
    data=w.data;
    if ~isfield(data,'npix')
        nd=numel(w.pax);
        sz=zeros(1,nd);
        for i=1:nd
            sz(i)=length(w.p{i})-1;
        end
        szarr=sz_to_sz_arr(sz);
    else
        szarr=size(data.npix);
        sz=szarr_to_sz(szarr);
        nd=numel(sz);
    end
    
else
    szarr=size(w.npix);
    sz=szarr_to_sz(szarr);
    nd=numel(sz);
end

%------------------------------------------------------------------------------
function szarr=sz_to_sz_arr(sz)
nd=size(sz,2);
if nd==0
    szarr=[1,1];
elseif nd==1
    szarr=[sz,1];
else
    szarr=sz;
end

%------------------------------------------------------------------------------
function sz=szarr_to_sz(szarr)
n=numel(szarr);
if n==2 && szarr(2)==1
    if szarr(1)>1
        sz=szarr(1);
    else
        sz=zeros(1,0);
    end
else
    sz=szarr;
end
