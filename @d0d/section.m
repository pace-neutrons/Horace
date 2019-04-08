function wout = section (win, varargin)
% Takes a section out of a 0-dimensional dataset. Dummy routine as sectioning not possible
%
% Syntax:
%   >> wout = section (win)
                                                        
% Original author: T.G.Perring
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargin==1
    wout = win; % trivial case of no sectioning being required
else
    wout = dnd(section(sqw(win),varargin{:}));
end
