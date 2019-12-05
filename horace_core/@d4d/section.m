function wout = section (win, varargin)
% Takes a section out of a 4-dimensional dataset.
%
% Syntax:
%   >> wout = section (win, [ax_1_lo, ax_1_hi], [ax_2_lo, ax_2_hi], [ax_3_lo, ax_3_hi], [ax_4_lo, ax_4_hi])
%
% Input:
% ------
%   win                 3-dimensional dataset.
%
%   [ax_1_lo, ax_1_hi]  Lower and upper limits for the first axis. Bins are retained whose
%                      centres lie in this range.
%                       To retain the limits of the input structure, type '', [], or the scalar '0'
%
%   [ax_2_lo, ax_2_hi]  Lower and upper limits for the second axis
%
%   [ax_3_lo, ax_3_hi]  Lower and upper limits for the third axis
%
%   [ax_4_lo, ax_4_hi]  Lower and upper limits for the fourth axis
%
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: to alter the limits of the first and third axes:
%   >> wout = section (win, [1.9,2.1], 0, [-0.55,-0.45], 0)
%                                                           

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)


% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

if nargin==1
    wout = win; % trivial case of no sectioning being required
else
    wout = dnd(section(sqw(win),varargin{:}));
end

