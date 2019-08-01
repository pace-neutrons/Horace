function obj = clear_mask(obj,idata_in)
% Clear masking of data points, so all data points are to be fitted
%
% Clear all masks:
%   >> obj = obj.clear_mask
%   >> obj = obj.clear_mask ('all')
%
% Clear masking for one or more particular datasets (ind an integer or integer array):
%   >> obj = obj.clear_mask (ind)
%
% For details about the keyword-value pairs, see <a href="matlab:help('mfclass/set_mask');">set_mask</a>
%
% See also set_mask add_mask
 
 
% Original author: T.G.Perring 
% 
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


% Catch case of no data
if isempty(obj.data_)
    if nargin>1
        error ('Cannot clear masking before any data sets have been set.')
    else
        return  % idata not given - nothing to do
    end
end

% Now check validity of input
[ok,mess,idata] = indicies_parse (idata_in, obj.ndatatot_, 'Dataset');
if ~ok, error(mess), end

% Set object
% ----------
obj.msk_(idata) = cellfun( @(x)true(size(x)), obj.msk_(idata), 'UniformOutput', false);
