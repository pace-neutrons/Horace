function wout = smooth (win,varargin)
% Smooth method - dataway to dnd object smoothing only.

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

if is_sqw_type(win)
    error('No smoothing of sqw data implemented. Convert to corresponding dnd object and smooth that.')
else
    wout = win;
    wout.data = smooth_dnd(win.data,varargin{:});
end
