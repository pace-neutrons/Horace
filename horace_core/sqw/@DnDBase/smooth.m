function wout = smooth(win, varargin)
% Smooth method - gataway to dnd object smoothing only.
wout = arrayfun(@(x)smooth_dnd_(x,false,varargin{:}),win);
