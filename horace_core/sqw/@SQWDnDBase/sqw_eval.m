function wout = sqw_eval(win, sqwfunc, pars, varargin)
% Calculate sqw for a model scattering function
%
%   >> wout = sqw_eval(win, sqwfunc, p)
%   >> wout = sqw_eval(___, '-all')
%   >> wout = sqw_eval(___, 'all', true)
%   >> wout = sqw_eval(___, '-average')
%   >> wout = sqw_eval(___, 'average', true)
%   >> sqw_eval(___, 'outfile', outfile)
%   >> wout = sqw_eval(___, 'outfile', outfile)
%   >> sqw_eval(__, 'outfile', outfile, 'filebacked', true)
%   >> wout = sqw_eval(__, 'filebacked', true)
%
% Input:
% ------
%   win        Dataset (or array of datasets) that provides the axes and points
%              for the calculation
%
%   sqwfunc     Handle to function that calculates S(Q, w)
%               Most commonly used form is:
%                   weight = sqwfunc (qh, qk, ql, en, p)
%                where
%                   qh,qk,ql,en Arrays containing the coordinates of a set of points
%                   p           Vector of parameters needed by dispersion function
%                              e.g. [A, js, gam] as intensity, exchange, lifetime
%                   weight      Array containing calculated spectral weight
%
%               More general form is:
%                   weight = sqwfunc (qh, qk, ql, en, p, c1, c2, ..)
%                 where
%                   p           Typically a vector of parameters that we might want
%                              to fit in a least-squares algorithm
%                   c1, c2, ...   Other constant parameters e.g. file name for look-up
%                              table
%
%   pars       Arguments needed by the function. Most commonly, a vector of parameter
%              values e.g. [A, js, gam] as intensity, exchange, lifetime. If a more general
%              set of parameters is required by the function, then
%              package these into a cell array and pass that as pars. In the example
%              above then pars = {p, c1, c2, ...}
%
% Keyword Arguments:
% ------------------
%   outfile    If present, the outputs will be written to the file of the given
%              name/path.
%              If numel(win) > 1, outfile must either be omitted or be a cell
%              array of file paths with equal number of elements as win.
%
%   all        If true, requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If false, then
%              the function will be returned only at those points of the dataset
%              that contain data_.
%               Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%              [default = false]
%
%   average    If true, requests that the calculated sqw be computed for the
%              average values of h, k, l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%              Applies only to the case of sqw object with pixel information
%              - it is ignored if dnd type object.
%              [default = false]
%
%   filebacked  If true, the result of the function will be saved to file and
%               the output will be a file path. If no `outfile` is specified,
%               a unique path within `tempdir()` will be generated.
%               Default is false.
%
% Note: all optional string input parameters can be truncated up to minimal
%       difference between them e.g. routine would accept 'al' and
%       'av', 'ave', 'aver' etc....
%
%
% Output:
% -------
%   wout        If `filebacked` is false, an sqw object or array of sqw objects.
%               If `filebacked` is true, a file path or cell array of file paths.
%               Output argument must be specified if `outfile` not given.
%
%===============================================================

[sqwfunc, pars, opts] = parse_eval_args(win, sqwfunc, pars, varargin{:});
if isempty(opts.outfile) || opts.filebacked
    % Make sure we have exactly one output argument if no outfile is specified,
    % otherwise this function would do nothing.
    % Even in filebacked mode, if no outfile is given, a random one is
    % generated. This is not much use to a user if it's not returned.
    nargoutchk(1, 1);
end

wout = copy(win);

for i=1:numel(wout)
    if has_pixels(wout(i))   % determine if object contains pixel data
        wout(i) = wout(i).sqw_eval_pix(sqwfunc, opts.average, pars, opts.outfile, i);
    else
        wout(i) = wout(i).sqw_eval_nopix(sqwfunc, opts.all, pars);
    end
end

end
