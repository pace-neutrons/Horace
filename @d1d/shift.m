function wout = shift(win, varargin)
% SHIFT - Moves a 1D dataset along the x-axis
%
% Syntax:
%   >> w_out = shift(w_in, delta)
%
% If DELTA is positive, then the spectrum starts and ends at more positive
% values of x.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if (nargin==1)
    wout = win;
else
    wout = dnd_data_op(win, @shift, 'd1d' , 1 , varargin{:});
end