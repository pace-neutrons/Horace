function [ok, mess, data_out] = dataset_remove (data_in, idata)
% Remove one or more datasets
%
%   >> [ok, mess, data_out] = dataset_remove (data_in, idata)
%
% Input:
% ------
%   data_in     Valid datasets as given by user (see is_valid_data for details)
%
%   idata       Indicies of datasets to be replaced. Assumesd to be a unique list
%              with valid indicies in the range 1 to number of datasets in data_in
%               If empty (i.e. []), then nothing is done
%               For all datasets, , set idata to 'all'
%
% Output:
% -------
%   data_out    Datasets with unwanted entries removed


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


% Initialise output (accounts also for trivial case of no data to replace)
ok = true;
mess = '';
data_out = data_in;
if isnumeric(idata) && numel(idata)==0
    return
end

% Update properties
if ischar(idata) && strcmpi(idata,'all')
    data_out = {};
    
elseif isnumeric(idata)
    [ndatatot, ndata] = data_indicies(data_in);
    
    % Datasets to keep, by data item
    keep = true(ndatatot,1);
    keep(idata) = false;            % set datasets to be removed to false
    keep = mat2cell(keep,ndata)';   % row cell array of logical columns, one per data item
    
    % Data item status
    delete_item = ~cellfun(@any,keep);
    nochange_item = cellfun(@all,keep);
    mixed_item = ~(delete_item | nochange_item);
    
    % Reshape keep arrays for mixed objects before slicing array
    % This means usual matlab rules about shapes are definitely applied
    % Note that the case of an item being {x,y,e} only has one dataset, so
    % the fact that prod(size)does not equal the number of datasets in this
    % case is irrelevant (as it is not a mixed_item)
    data_out(mixed_item) = cellfun(@(data,keep)data(reshape(keep,size(data))),...
        data_in(mixed_item),keep(mixed_item),'UniformOutput',false);
    
    % Filter out completely deleted data items
    data_out = data_out(~delete_item);
    
    % Catch special case of removing all but one of a cell array of cell
    % arrays - to avoid {{x,y,e}} ?
    
else
    error('Logic error. Contact developers')
end
