function display_single (w)
% Display useful information from a d2d object
%
% Syntax:
%
%   >> display_single(w)

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

display(sqw(w))
