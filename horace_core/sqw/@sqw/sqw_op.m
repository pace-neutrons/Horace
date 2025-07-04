function wout = sqw_op(obj, sqwop_func, pars, varargin)
% Perform an operation or set of operations over pixels defined
% by user provided sqw_func.
%
%   >> wout = sqw_op(win, sqwfunc, p)
%   >> wout = sqw_op(__,PageOp_processor)
%   >> sqw_op(__, 'outfile', outfile, 'filebacked', true)
%   >> wout = sqw_op(__, '-filebacked')
%
% Input:
% ------
%   obj    --   sqw object (or array of objects) used
%               as the source of coordinates and other information for
%               sqwop_func
% sqwop_func
%          --  Handle to function that performs operation
%   pars   --  Cellarray of arguments needed by the function.
%              The function would have a form
%              sqwop_func(PageOp_sqw_eval_obj_instance,pars{:});
% Optional:
% ------------------
% PageOp_processor
%          -- the instance of a class-child of PageOp_sqw_op class, which
%             provides additional functionality to PageOp_sqw_op operation.
%
% Keyword Arguments:
% ------------------
%   outfile    If present, the outputs will be written to the file of the given
%              name/path.
%              If numel(win) > 1, outfile must either be omitted or be a cell
%              array of file paths with equal number of elements as win.
%
%   filebacked with true/false value following or key '-filebacked'
%               If true, or key '-filebacked' present,
%               the result of the function will be saved to file and
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
        'Contact HoraceHelp@stfc.ac.uk if you need it with the description of its meaning in your case'])
end

% if test_input_parsing option provided among input keys, we are testing input
% parameters parsing so would exit returning input parameters
if opts.test_input_parsing
    wout = opts;
    % return input parameters without processing them
    return
end


wout = cell(1,numel(obj));
for i=1:numel(obj)
    wout{i} = sqw_op_single_(obj(i),sqwop_func,pars,opts,i);
end
wout = [wout{:}];
end
