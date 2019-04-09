function [ndatatot, ndata, item, ix] = data_indicies(data)
% Get the values for derived data indicies
%
%   >> [ndatatot, ndata, item, ix] = data_indicies(data)
%
% Input:
% ------
%   data    Cell array (row) with input data as provided by user (i.e.
%          elements may be cell arrays of {x,y,e}, structure arrays, object
%          arrays); a special case is thee elements x, y, e.
%
% Output:
% -------
%   ndatatot Total number of datasets
%
%   ndata   Row vector with number of datasets in each item in the cell array
%          of datasets.
%           If no data, ndata = []
%
%   item    Column vector with index of item in the cell array of datasets
%           If no data, ix = zeros(0,1)
%
%   ix      Column vector with index within the item in the cell array of
%          datasets
%           If no data, ix = zeros(0,1)


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)


if ~isempty(data)
    if numel(data)==3 && isnumeric(data{2})
        % Special case of {x,y,e}
        item = 1;
        ix = 1;
    else
        % Get number of datasets in each item in data
        % Must carefully treat the case of a data item being {x,y,e} or
        % {{x1,y1,e1},{x2,y2,e2},...} (including case of {{x,y,e}} )
        ndata = cellfun(@numel,data); % will be wrong for items like {x,y,e}
        
        celldata = cellfun(@iscell,data);     
        single = cellfun(@cell_is_xye,data(celldata));
        n = ndata(celldata);
        n(single) = 1;
        ndata(celldata) = n;
        
        % Now get the other terms
        ndatacum=cumsum(ndata)';
        ndatacumshift=1+[0;ndatacum(1:end-1)];
        
        ndatatot=ndatacum(end);
        
        item=zeros(ndatatot,1);
        item(ndatacumshift)=1;
        item=cumsum(item);
        
        ix=ones(ndatatot,1);
        ix(ndatacumshift)=ix(ndatacumshift)-[0,ndata(1:end-1)]';
        ix=cumsum(ix);
    end
    
else
    item = zeros(0,1);
    ix = zeros(0,1);
    
end

%------------------------------------------------------------------------------
function status = cell_is_xye(var)
% Assuming a cellarray is one of:
% - {x,y,e}
% - {{x1,y1,e1},{x2,y2,e2},...} (including case of {{x,y,e}} )
% this function returns true if the former, false if the latter
status = ~all(cellfun(@iscell,var(:)));
