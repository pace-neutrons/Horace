function obj = clear_mask(obj,idata_in)
% Clear masking
%
% Clear all masks
%   >> obj = obj.clear_mask
%
% Clear a particular mask or mask for a set of datasets
%   >> obj = obj.clear_mask (idata)     % idata an integer or integer array


% Catch case of no data
if isempty(obj.data_)
    if nargin>1
        error ('Cannot clear masking before any data sets have been set.')
    else
        return  % idata not given - nothing to do
    end
end

% Now check validity of input
[ok,mess,idata] = dataset_indicies_parse (idata_in, obj.ndatatot_);
if ~ok, error(mess), end

% Set object
% ----------
obj.msk_(idata) = cellfun( @(x)true(size(x)), obj.msk_(idata), 'UniformOutput', false);
