function [proj, pbin] = get_proj_and_pbin(w)
% Retrieve the projection and binning of an sqw object
%
%   >> [proj, pbin] = get_proj_and_pbin (w)
%
% Input:
% ------
%   w       sqw object
%
% Output:
% -------
%   proj    Projection as a aProjectionBase object
%   pbin    Cell array, a row length 4, of the binning description of the
%           sqw object

proj = repmat(line_proj, size(w));
pbin = repmat({{[],[],[],[]}}, size(w));
for i=1:numel(w)
    [proj(i), pbin{i}] = get_proj_and_pbin(w(i).data);
end
