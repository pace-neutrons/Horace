function wout = combine(win,varargin)
% Combines one dimensional datasets with identical x axes into a new workspace.
% The data set are "glued" together at the points x1,x2..xn-1
% with a smoothing function that extends +/-(delta/2) about those points.
%
% Syntax:
%   >> wout = combine (w1, x1, w2, delta)                   % minimum case
%
%   >> wout = combine (w1, x1, w2, x2 ... xn-1, wn, delta)  % general case

wout = dnd_data_op(win, @combine, 'd1d' , 1, varargin{:});