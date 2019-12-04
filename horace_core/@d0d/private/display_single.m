function display_single (w)
% Display useful information from a d2d object
%
% Syntax:
%
%   >> display_single(w)

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

display(sqw(w))
