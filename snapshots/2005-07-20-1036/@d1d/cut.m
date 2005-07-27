function wout = cut (win, varargin)
% Average over an interval along one or more axes of a dataset object to
% produce a dataset object with reduced dimensionality.
%
% Syntax:
%   >> dout = cut_data (din, iax_1, iax1_range, iax_2, iax2_range, ...)
%
% Input:
% ------
%   din             Data from which a reduced dimensional manifold is to be taken.
%                  Type >> help dnd_checkfields for a full description of the fields
%
%   iax_1           Index of further axis to integrate along. The labels of the axis
%                  is the plot axis index i.e. 1=plot x-axis, 2=plot y-axis etc.
%
%   iax_1_range     Integration range [iax_lo, iax_hi] for this integration axis
%
%   iax_2       -|  The same for second additional integration axis
%   iax_2_range -| 
%
%       :
%
% Output:
% -------
%   dout            Output dataset. Its elements are the same as those of din,
%                  appropriately updated.
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if nargin==1
    wout = win; % trivial case of no integration axes being provided
else
    wout = dnd_create (cut_data (get(win), varargin));
end
