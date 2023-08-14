function [proj, pbin] = get_proj_and_pbin(w)
% Retrieve the projection and binning of an sqw or dnd object
%
%   >> [proj, pbin] = get_proj_and_pbin (w)
%
% Input:
% ------
%   w       sqw object
%
% Output:
% -------
%   proj    Projection as a projaxes object
%   pbin    Cell array, a row length 4, of the binning description of the
%          sqw object

% T.G.Perring   30 September 2018

if numel(w)==1
    [proj, pbin] = get_proj_and_pbin_single(w);
elseif numel(w)>1
    proj = repmat(line_proj, size(w));
    pbin = repmat({{[],[],[],[]}}, size(w));
    for i=1:numel(w)
        [proj(i), pbin{i}] = get_proj_and_pbin_single(w(i));
    end
end

%------------------------------------------------------------------------------
function [proj, pbin] = get_proj_and_pbin_single(data)

% Get projection
% --------------------------
proj = data.proj;
% Get binning
% -------------------------
pbin = data.axes.get_cut_range('-full_range');
