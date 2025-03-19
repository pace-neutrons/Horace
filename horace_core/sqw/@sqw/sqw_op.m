function obj = sqw_op(obj, sqwop_func, pars, varargin)
% Perform an operation or set of operations over pixels defined
% by user provided sqw_func.
%
%   >> wout = sqw_op(win, sqwfunc, p)
%   >> sqw_op(__, 'outfile', outfile, 'filebacked', true)
%   >> wout = sqw_op(__, 'filebacked', true)
%
% Input:
% ------
%   obj        sqw object (or array of objects) used
%              as the source of oordinates for sqwfunc:
%              namely the pixel coordinates or their cell  average.
%
%  sqwop_func  Handle to function that calculates operation
%   pars       Cellarray of arguments needed by the function.
%              The function would have a form
%              sqwop_func(PageOp_sqw_eval_obj_instance,pars{:});
%
% Keyword Arguments:
% ------------------
%   outfile    If present, the outputs will be written to the file of the given
%              name/path.
%              If numel(win) > 1, outfile must either be omitted or be a cell
%              array of file paths with equal number of elements as win.
%
%   filebacked  If true, the result of the function will be saved to file and
%               the output will be a file path. If no `outfile` is specified,
%               a unique path within `tempdir()` will be generated.
%               Default is false so resulting object intended to be put in
%               memory but if the resulting object is too big to
%               be stored in memory, result will be filebacked.
%
%
% Output:
% -------
%   obj        If `filebacked` is false, an sqw object or array of sqw objects.
%              If `filebacked` is true, a file path or cell array of file paths.
%              Output argument must be specified if `outfile` not given.
%
%==========================================================================
[sqwop_func, pars, opts] = parse_eval_args(obj, sqwop_func, pars, varargin{:});
if isempty(opts.outfile) || (isscalar(opts.outfile) && isempty(opts.outfile{1})) || opts.filebacked
    % Make sure we have exactly one output argument if no outfile is specified,
    % otherwise this function would do nothing.
    % Even in filebacked mode, if no outfile is given, a random one is
    % generated. This is not much use to a user if it's not returned.
    if nargout ~=1
        error('HORACE:sqw_op:invalid_argument',[ ...
            'This method request single output argument unless output filename to save result is specified.\n' ...
            'Filename is missing and got: %d output argumets'], ...
            nargout)
    end
end
if  opts.average
    error('HORACE:PageOp_sqw_op:not_implemented', [ ...
        '"-average" option is not currently implemented for sqw_op.' ...
        'Contact HoraceHelp@stfc.ac.uk if you need it'])
end

for i=1:numel(obj)
    obj(i) = sqw_op_single_(obj(i),sqwop_func,pars,opts.outfile{i});
end
end
