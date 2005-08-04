function wout = section (win, varargin)
% Takes a section out of a 2-dimensional dataset.
%
% Syntax:
%   >> wout = section (win, [ax_1_lo, ax_1_hi], [ax_2_lo, ax_2_hi])
%
% Input:
% ------
%   win                 2-dimensional dataset.
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits for the first axis.
%                       To retain the limits of the input structure, type the scalar '0'
%
%   [ax_2_lo, ax_2_hi]  Lower and upper limits for the second axis
%
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: to alter the limits of the first axis:
%   >> wout = section (win, [1.9,2.1], 0)
%                                                           

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if nargin==1
    wout = win; % trivial case of no sectioning being required
else
    wout = dnd_create(dnd_section(get(win), varargin));
end