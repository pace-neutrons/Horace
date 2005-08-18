function wout = compact (win)
% Squeezes the data range in a 1-dimensional dataset to eliminate empty bins
%
% Syntax:
%   >> wout = compact(win)
%
% Input:
% ------
%   win         Input dataset 
%
% Output:
% -------
%   wout        Output dataset, with length of axes reduced to yield the
%               smallest cuboid that contains the non-empty bins.
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring


wout = dnd_create(dnd_compact(get(win)));
