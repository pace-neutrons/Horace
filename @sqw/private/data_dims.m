function [nd,sz,szarr] = data_dims(data)
% Find number of dimensions and extent along each dimension of the signal arrays.
%
%   >> [nd,sz,szarr]=data_dims(data)
%
% Input:
% ------
%   data    Data field from an sqw object or structure
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

% Only needs the header part of the data field

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

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
