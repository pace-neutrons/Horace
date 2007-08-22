function wout = regroup(win, varargin)
% REGROUP  Rebins so that the new bin boundaries are
%          always coincident with boundaries in the input 1D dataset. This avoids
%          correlated error bars between the contents of the bins.
%
% Syntax :
%
%   >> wout = regroup (w1,xlo,dx,xhi)
%
%   >> wout = regroup (w1,[xlo,dx,xhi])
%
%  Syntax is the same as the IXTdataset_1d operation. See this help for
%  details on syntax.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% The help section above should be identical to that for spectrum/regroup

if (nargin==1)
    wout = win;
else
    wout = dnd_data_op(win, @regroup, 'd1d' , 1 , varargin{:});
end