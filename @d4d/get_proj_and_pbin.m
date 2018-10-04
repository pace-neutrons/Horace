function [proj, pbin] = get_proj_and_pbin (w)
% Reverse engineer the projection and binning of a d4d object
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


[proj, pbin] = get_proj_and_pbin (sqw(w));
