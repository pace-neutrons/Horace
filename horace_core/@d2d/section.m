function wout = section (win, varargin)
% Takes a section out of a 2-dimensional dataset.
%
% Syntax:
%   >> wout = section (win, [ax_1_lo, ax_1_hi], [ax_2_lo, ax_2_hi])
%
% Input:
% ------
%   win                 2-dimensional dataset.
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits for the first axis. Bins are retained whose
%                      centres lie in this range.
%                       To retain the limits of the input structure, type '', [], or the scalar '0'
%
%   [ax_2_lo, ax_2_hi]  Lower and upper limits for the second axis
%
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: to alter the limits of the first axis:
%   >> wout = section (win, [1.9,2.1], 0)
%                                                           

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargin==1
    wout = win; % trivial case of no sectioning being required
else
    wout = dnd(section(sqw(win),varargin{:}));
end
