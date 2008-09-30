function wout = compact (win)
% Squeezes the data range in an sqw object to eliminate empty bins
%
% Syntax:
%   >> wout = compact(win)
%
% Input:
% ------
%   win         Input object 
%
% Output:
% -------
%   wout        Output object, with length of axes reduced to yield the
%               smallest cuboid that contains the non-empty bins.
%

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

if is_sqw_type(win)
    wout = win;
    wout.data = sqw_compact(win.data);
else
    wout = win;
    wout.data = dnd_compact(win.data);
end
