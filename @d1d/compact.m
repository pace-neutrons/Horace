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
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(compact(sqw(win)));
