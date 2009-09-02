function wout = permute (win,varargin)
% Permute the order of the display axes. Syntax the same as the matlab array permute function
%
% Syntax:
%   >> wout = permute (win)         % swap display axes
%   >> wout = permute (win, [2,1])  % equivalent syntax


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(permute(sqw(win),varargin{:}));
