function [nd,sz] = sqw_data_dims(data)
% Find number of dimensions and extent along each dimension of
% the signal arrays.
%
%   >> [nd,sz]=sqw_data_dims(data)
%
% - If 0D sqw object, nd=[], sz=zeros(1,0)
% - if 1D sqw object, nd=1,  sz=n1
% - If 2D sqw object, nd=2,  sz=[n1,n2]
% - If 3D sqw object, nd=2,  sz=[n1,n2,n3]   even if n3=1
% - If 4D sqw object, nd=2,  sz=[n1,n2,n3,n4]  even if n4=1

% Only needs the header part of the data field

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

nd=numel(data.pax);
sz=zeros(1,nd);
for i=1:nd
    sz(i)=length(data.p{i})-1;
end
