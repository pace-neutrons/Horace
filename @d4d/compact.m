function wout = compact (win)
% Squeezes the data range in a d2d object to eliminate empty bins
%
% Syntax:
%   >> wout = compact(win)
%
% Input:
% ------
%   win         Input object 
%
% Output:
% -------
%   wout        Output object, with length of axes reduced to yield the
%               smallest cuboid that contains the non-empty bins.
%

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(compact(sqw(win)));
