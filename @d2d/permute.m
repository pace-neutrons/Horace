function wout = permute (win,varargin)
% Permute the order of the display axes. Syntax the same as the matlab array permute function
%
% Syntax:
%   >> wout = permute (win)         % swap display axes
%   >> wout = permute (win, [2,1])  % equivalent syntax


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

wout=dnd(permute(sqw(win),varargin{:}));
