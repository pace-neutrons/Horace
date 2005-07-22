function wout = cut (win, varargin)
% Average over an interval along one or more axes of a 2-dimensional dataset
% to produce a dataset object with reduced dimensionality.
%
% Syntax:
%   >> wout = cut (win, iax_1, iax1_range, iax_2, iax2_range, ...)
%
% Input:
% ------
%   win             Data from which a reduced dimensional manifold is to be taken.
%
%   iax_1           Index of further axis to integrate along. The labels of the axis
%                  is the plot axis index i.e. 1=plot x-axis, 2=plot y-axis etc.
%
%   iax_1_range     Integration range [iax_lo, iax_hi] for this integration axis
%
%   iax_2       -|  The same for second additional integration axis
%   iax_2_range -| 
%
%
% Output:
% -------
%   wout            Output dataset.
%
% Example: average over an intereval of the second axis only:
%   >> wout = cut (win, 2, [1.2, 1.4])

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if nargin==1
    wout = win; % trivial case of no integration axes being provided
else
    wout = dnd_create(dnd_cut(get(win), varargin));
end
