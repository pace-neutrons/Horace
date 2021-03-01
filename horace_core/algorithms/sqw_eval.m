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
% Keywords:
% ---------
% filebacked_pix   Set to true if pixels are to be file-backed.
%
%  See sqw/sqw_eval for more options.
%

% Strip flags from varargin before passing args to loader
flags = {'-all', '-average'};
[~, ~, ~, ~, args] = parse_char_options(varargin, flags);

% Convert inputs into an sqw/dnd object/array of objects
[win, args] = load_sqw_dnd(win, args{:});

% TODO: do we need this if, we return file name or object
if nargout > 0
    wout = sqw_eval(win, sqwfunc, pars, args{:});
else
    sqw_eval(win, sqwfunc, pars, args{:});
end

end
