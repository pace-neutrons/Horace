function [nd,sz,nse_size] = data_dims(obj)
% Find number of dimensions and extent along each dimension of
% the signal arrays.
%
%   >> [nd,sz,nse_size]=data_dims(data)
%
% - If 0D sqw object, nd=0,  sz=[1,1]
% - if 1D sqw object, nd=1,  sz=[n1,1];
% - If 2D sqw object, nd=2,  sz=[n1,n2];
% - If 3D sqw object, nd=3,  sz=[n1,n2,n3];    even if n3=1
% - If 4D sqw object, nd=4,  sz=[n1,n2,n3,n4]; even if n4=1
%
% nse_size -- the size of accumulator array to be used if data are binned
%             over sz-sized grid

nd=numel(obj.pax);
sz=zeros(1,nd);

for i=1:nd
    sz(i)=length(obj.p{i})-1;
end
if nd == 0
    sz = [1,1];
    nse_size = [1,1];
end
if nd == 1
    sz = [sz,1];
end
if nargout>2
    is_size = arrayfun(@(x)(x>1),sz);
    nse_size = sz(is_size);
    if numel(nse_size)<2
        if numel(nse_size)==1
            nse_size = [nse_size,1];
        else
            nse_size = [1,1];
        end
    end
end
