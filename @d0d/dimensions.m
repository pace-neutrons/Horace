function [nd,sz] = dimensions(w)
% Find number of dimensions and extent along each dimension of
% the signal arrays. 
% - If 0D sqw object, nd=0,  sz=zeros(1,0) (nb: []==zeros(0,0))
% - if 1D sqw object, nd=1,  sz=n1
% - If 2D sqw object, nd=2,  sz=[n1,n2]
% - If 3D sqw object, nd=3,  sz=[n1,n2,n3]   even if n3=1
% - If 4D sqw object, nd=4,  sz=[n1,n2,n3,n4]  even if n4=1
%
% The convention is that size(sz)=1 x ndim
%
%   >> [nd,sz]=dimensions(w)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

%Extend to work on arrays

% nd=numel(w.pax);
% sz=zeros(1,nd);
% for i=1:nd
%     sz(i)=length(w.p{i})-1;
% end

for j=1:numel(w)
    nd=numel(w(j).pax);
    sz{j}=zeros(1,nd);
    for i=1:nd
        sz{j}(i)=length(w(j).p{i})-1;
    end
end

if numel(w)==1
    sz=cell2mat(sz);
end
