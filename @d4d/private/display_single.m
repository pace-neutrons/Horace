function display_single (w)
% Display useful information from a d2d object
%
% Syntax:
%
%   >> display_single(w)

% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

display(sqw(w))
