function wout = permute (win,varargin)
% Permute the order of the display axes. Syntax the same as the matlab array permute function
%
% Syntax:
%   >> wout = permute (win)         % swap display axes
%   >> wout = permute (win, [2,1])  % equivalent syntax


% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(permute(sqw(win),varargin{:}));
