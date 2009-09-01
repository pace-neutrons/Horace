function wout = section (win, varargin)
% Takes a section out of a 0-dimensional dataset. Dummy routine as sectioning not possible
%
% Syntax:
%   >> wout = section (win)
                                                        
% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargin==1
    wout = win; % trivial case of no sectioning being required
else
    wout = dnd(section(sqw(win),varargin{:}));
end
