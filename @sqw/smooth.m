function wout = smooth (win,varargin)
% Smooth method - dataway to dnd object smoothing only.

% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

if is_sqw_type(win)
    error('No smoothing of sqw data implemented. Convert to corresponding dnd object and smooth that.')
else
    wout = win;
    wout.data = smooth_dnd(win.data,varargin{:});
end
