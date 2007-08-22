function wout = cut (win, varargin)
% Average over an interval along the x-axis of a 1-dimensional dataset
% to produce a dataset object with reduced dimensionality.
%
% Syntax:
%   >> wout = cut (win, xlo, xhi)
%   >> wout = cut (win, [xlo, xhi])     
%   >> wout = cut (win, 1, [xlo, xhi])  % for syntactical consistency with 2,3,4 dimensional cut
%
% Input:
% ------
%   win             Data from which a reduced dimensional manifold is to be taken.
%   xlo             Lower integration limit
%   xhi             Upper integration limit
%
% Output:
% -------
%   wout            Output dataset. Its elements are the same as those of din,
%                  appropriately updated.
%
% Example:
%   >> wout = cut (win, 1.9, 2.3)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if nargin==1
    wout = win; % trivial case of no integration axes being provided
else
    if length(varargin)==2 && (isa_size(varargin{1},[1,1],'double') && isa_size(varargin{2},[1,1],'double'))  % syntax must be cut(w1,xlo,xhi)
        args = {1, [varargin{1}, varargin{2}]};
    elseif length(varargin)==1 && isa_size(varargin{1},[1,2],'double')  % syntax must be cut(w1,[xlo,xhi])
        args = {1, varargin{1}};
    else
        args = varargin;
    end
    wout = dnd_create (dnd_cut(get(win), args));
end
