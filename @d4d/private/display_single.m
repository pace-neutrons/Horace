function display_single (w)
% Display useful information from a d2d object
%
% Syntax:
%
%   >> display_single(w)

% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

display(sqw(w))
