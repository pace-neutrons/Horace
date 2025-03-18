function obj = sqw_op(obj, sqwfunc, pars, varargin)
% Perform an operation or set of operations over pixels defined
% by user provided sqw_func.
%
%   >> wout = sqw_op(win, sqwfunc, p)
%   >> wout = sqw_op(___, '-all')
%   >> wout = sqw_op(___, 'all', true)
%   >> wout = sqw_op(___, '-average')
%   >> wout = sqw_op(___, 'average', true)
%   >> sqw_op(___, 'outfile', outfile)
%   >> wout = sqw_op(___, 'outfile', outfile)
%   >> sqw_op(__, 'outfile', outfile, 'filebacked', true)
%   >> wout = sqw_op(__, 'filebacked', true)
%
% Input:
% ------
%   obj        sqw object (or array of objects) used
%              as the source of oordinates for sqwfunc:
%              namely the pixel coordinates or their cell  average.
%
%   sqwfunc    Handle to function that calculates operation
%   pars       Cellarray of arguments needed by the function.
%
% Keyword Arguments:
% ------------------
%   outfile    If present, the outputs will be written to the file of the given
%              name/path.
%              If numel(win) > 1, outfile must either be omitted or be a cell
%              array of file paths with equal number of elements as win.
%
%   -all or pair of arguments: [all,[true|false]]
%              If true, requests that the calculated sqw be returned over
%              the whole of the domain of the input dataset. If false, then
%              the function will be returned only at those points of the
%              dataset that contain data_.
%              Applies only to input with no pixel information - it is
%              ignored if input is full sqw object.
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
%               Default is false so resulting object intended to be put in
%               memory but if the resulting object is too big to
%               be stored in memory, result will be filebacked.
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
        error('HORACE:sqw_op:invalid_argument', ...
            'This method request single output argument. Got: %d', ...
            nargout)
    end
end

for i=1:numel(obj)
    obj(i) = sqw_op_single_(obj(i),sqwfunc, opts.average, pars, opts.outfile{i});
end

end
