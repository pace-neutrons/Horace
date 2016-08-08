function [ndata,ndatatot,item,ix] = data_indicies(ndim)
% Get the values for derived data indicies from ndim
% 
%   >> [ndata,ndatatot,item,ix] = data_indicies(ndim)
%
% Input:
% ------
%   ndim    Cell array of arrays containing the number of dimensions of each
%          item in the cell array of datasets.
%           If ndim is the empty cell array, this corresponds to no data
%
% Output:
% -------
%   ndata   Row vector with number of datasets in each item in the cell array
%          of datasets.
%           If no data, ndata = []
%         
%  ndatatot Total number of datasets (==sum(ndata_))
%           If no data, ndatatot = 0
%         
%   item    Column vector with index of item in the cell array of datasets
%           If no data, ndatatot = 0
%         
%   ix      Column vector with index within the item in the cell array of
%          datasets
%           If no data, ix = zeros(0,1)
        
if ~isempty(ndim)
    ndata = cellfun(@numel,ndim);
    
    ndatacum=cumsum(ndata)';
    ndatacumshift=1+[0;ndatacum(1:end-1)];
    
    ndatatot=ndatacum(end);
    
    item=zeros(ndatatot,1);
    item(ndatacumshift)=1;
    item=cumsum(item);
    
    ix=ones(ndatatot,1);
    ix(ndatacumshift)=ix(ndatacumshift)-[0,ndata(1:end-1)]';
    ix=cumsum(ix);
    
else
    ndata = [];
    ndatatot = 0;
    item = zeros(0,1);
    ix = zeros(0,1);
    
end
