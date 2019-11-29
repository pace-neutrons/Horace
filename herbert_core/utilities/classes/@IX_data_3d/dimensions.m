function [nd,sz] = dimensions(w)
% Find number of dimensions and extent along each dimension of the signal arrays. 
% - If 0D IX_dataset_nd object, nd=0,  sz=zeros(1,0) (nb: []==zeros(0,0))
% - if 1D IX_dataset_nd object, nd=1,  sz=n1
% - If 2D IX_dataset_nd object, nd=2,  sz=[n1,n2]
% - If 3D IX_dataset_nd object, nd=3,  sz=[n1,n2,n3]   even if n3=1
% - If 4D IX_dataset_nd object, nd=4,  sz=[n1,n2,n3,n4]  even if n4=1
%
% The convention is that size(sz)=1 x ndim
%
%   >> [nd,sz]=dimensions(w)

% Original author: T.G.Perring

nd=3;
sz=[size(w.signal),ones(1,nd-numel(size(w.signal)))];   % for any nd; works even if nd=1, i.e. ones(1,-1)==[]
