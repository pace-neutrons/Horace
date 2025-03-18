function wout = sqw_op(win, sqwfunc, pars, varargin)
% Apply operation or sequence of operations over input sqw files 
% The operations act on pixels and are defined in user provided 
% sqwfunc which should accept PageOp_sqw_op object as first argument
% 
%
%   >> wout = sqw_op(win, sqwfunc, p)
%
% Input:
% ------
%   win        Dataset file (or cell array) that provides the axes
%              and points for the calculation
%
%  See sqw/sqw_eval for more options.
%


if ~iscell(win)
    win = {win};
end
n_inputs = numel(win);

ldrs = cell(size(win));
for i=1:n_inputs
    ldrs{i} = sqw_formats_factory.instance.get_loader(win{i});
    if ~ldrs{i}.sqw_type
        error('HORACE:sqw_op:invalid_argument', ...
            'input file N%d with name %s is not an sqw-type file', ...
            i,win{i});
    end
end
wout = repmat(sqw(),size(win));
for i=1:n_inputs
    win = sqw(ldrs{i});
    wout(i) = sqw_op(win,sqwfunc,pars,varargin{:});
end
end
