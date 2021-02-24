function wout = sqw_eval(win, sqwfunc, pars, varargin)
% Calculate sqw for a model scattering function
%
%   >> wout = sqw_eval(win, sqwfunc, p)
%
% Input:
% ------
%   win        Dataset sqw/file (or array of datasets) that provides the axes
%              and points for the calculation
%
%  See sqw/sqw_eval for more options.
%
win = load_sqw_dnd(win, varargin{:});

if nargout > 0
    wout = sqw_eval(win, sqwfunc, pars, varargin{:});
else
    sqw_eval(win, sqwfunc, pars, varargin{:});
end

end
