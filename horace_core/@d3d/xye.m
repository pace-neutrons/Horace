function S=xye(w,null_value)
% Get the bin centres, intensity and error bar for a d3d dataset
%
%   >> S = xye(w)
%   >> S = xye(w, null_value)
%
% Input:
% ------
%   w       d3d object or array of objects 
%   null_value  Numeric value to substitute for the intensity in bins
%           with no data.
%           Default: NaN
%
% Output:
% -------
%   S       Structure with the following fields:
%
%       x   cell array {x1,x2,x3} where x1, x2, x3 are the bin centres of the 
%           three plot axes (column vectors)
%
%       y   Column vector of intensities
%
%       e   Column vector of error bars


% The following code should be independent of the dimensionality
if nargin==1
    null_value=NaN;
else
    if ~isnumeric(null_value) || ~isscalar(null_value)
        error('Null value must be a numeric scalar')
    end
end

S=xye(sqw(w),null_value);
