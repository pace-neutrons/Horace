function wout = minus(w1,w2)
% MINUS  Implement w1 - w2 for a 1D dataset.
%
%   >> w = w1 - w2
%
% See dnd_binary_op and libisis binary operations documentation for more
% details 

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

wout = dnd_binary_op(w1,w2,@minus,'d1d',1);