function wout = section (win, varargin)
% Takes a section out of a 1-dimensional dataset.
%
% Syntax:
%   >> wout = section (win, [ax_1_lo, ax_1_hi])
%
% Input:
% ------
%   win                 2-dimensional dataset.
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits.
%                       To retain the limits of the input structure, type the scalar '0'
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: 
%   >> wout = section (win, [1.9,2.1])
%                                                           

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if nargin==1
    wout = dnd_create(dnd_section(get(win)));
else
    wout = dnd_create(dnd_section(get(win), varargin));
end