function wout = sqw_eval(obj, sqwfunc, pars, varargin)
% Calculate sqw for a model scattering function over input sqw object
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
%   obj        SQWDnDBase object (or array of objects) used
%              as the source of hkle coordinates for sqwfunc:
%            - for dnd this is the image axis bin centre coordinates
%            - for sqw this is the pixel coordinates or their cell
%              average.
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
%   outfile    If present (followed by actual name of the file), the outputs 
%              will be written to the file of the given  name/path.
%              If numel(win) > 1, outfile must either be omitted or be a cell
%              array of file paths with equal number of elements as win.
%
%   -all       If present, requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If false, then
%              the function will be returned only at those points of the dataset
%              that contain data_.
%               Applies only to input with no pixel information - it is ignored if
%              full sqw object.
%              [default = false]
%
%   -average   If present, requests that the calculated sqw be computed for the
%              average values of h, k, l of the pixels in a bin, not for each
%              pixel individually. Reduces cost of expensive calculations.
%              Applies only to the case of sqw object with pixel information
%              - it is ignored if dnd type object.
%              [default = false]
%
%  -filebacked  If present, the result of the function will be saved to file and
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
%   obj        If `filebacked` is false, an sqw object or array of sqw objects.
%              If `filebacked` is true, a file path or cell array of file paths.
%              Output argument must be specified if `outfile` not given.
%
%===============================================================

[sqwfunc, pars, opts] = parse_eval_args(obj, sqwfunc, pars, varargin{:});
if isempty(opts.outfile) || (isscalar(opts.outfile) && isempty(opts.outfile{1})) || opts.filebacked
    % Make sure we have exactly one output argument if no outfile is specified,
    % otherwise this function would do nothing.
    % Even in filebacked mode, if no outfile is given, a random one is
    % generated. This is not much use to a user if it's not returned.
    if nargout ~=1
        error('HORACE:sqw_eval:invalid_argument', ...
            'This method request single output argument. Got: %d', ...
            nargout)
    end
end

wout = cell(1,numel(obj));
for i=1:numel(obj)
    if has_pixels(obj(i))   % determine if object contains pixel data
        optl = opts;
        optl.outfile = opts.outfile{i};
        wout{i} = obj(i).sqw_eval_pix(sqwfunc,pars,optl);
    else
        wout{i} = obj(i).sqw_eval_nopix(sqwfunc, pars,opts);
    end
end
wout = [wout{:}];

end
