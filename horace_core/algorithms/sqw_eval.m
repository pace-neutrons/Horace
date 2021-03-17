function wout = sqw_eval(win, sqwfunc, pars, varargin)
% Calculate sqw for a model scattering function
%
%   >> wout = sqw_eval(win, sqwfunc, p)
%
% Input:
% ------
%   win        Dataset file (or cell array) that provides the axes
%              and points for the calculation
%
%  See sqw/sqw_eval for more options.
%

% Strip flags from varargin before passing args to loader
flags = {'-all', '-average'};
[~, ~, ~, ~, args] = parse_char_options(varargin, flags);

% Convert inputs into an sqw/dnd object/array of objects
win = load_sqw_dnd(win, args{:});

wout = sqw_eval(win, sqwfunc, pars, varargin{:});

end
