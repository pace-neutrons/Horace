function wout = sqw_op(win, sqw_opfunc, pars, varargin)
% Apply operation or sequence of operations over input sqw files or sqw
% objects packed in input cellarray.
%
% The operations act on pixels and are defined in user provided
% sqw_opfunc which should accept PageOp_sqw_op object as first argument
%
%
%   >> wout = sqw_op(win, sqw_opfunc, p)
%
% Input:
% ------
%   win        Dataset file (or cell array) that provides filenames or sqw
%              objects for
%              and points for the calculation
%   pars       Cellarray of arguments needed by the function.
%              The function would have a form
%              sqwop_func(PageOp_sqw_eval_obj_instance,pars{:});
%
% Returns:
%
% wout      -- array of sqw objects or filebacked sqw objects-- the results
%              of applying sqw_opfunc to them.
%
%

if ~iscell(win)
    win = {win};
end
n_inputs = numel(win);

ldrs = cell(size(win));
sqw_obj = false(size(win));
for i=1:n_inputs
    if istext(win{i})
        ldrs{i} = sqw_formats_factory.instance.get_loader(win{i});
        if ~ldrs{i}.sqw_type
            error('HORACE:sqw_op:invalid_argument', ...
                'input file N:%d with name %s is not an sqw-type file', ...
                i,win{i});
        end
    elseif isa(win{i},'sqw')
        sqw_obj(i) = true;
        ldrs{i} = win{i};
    else
        error('HORACE:sqw_op:invalid_argument', ...
            'Input object N:%d is not an sqw object. Its class is: %s',...
            i,class(win{i}));
    end
end
if nargout>0
    wout = repmat(sqw(),size(win));
end
for i=1:n_inputs
    if sqw_obj(i)
        win = ldrs{i};
    else
        win = sqw(ldrs{i});
    end
    if nargout > 0
        wout(i) = sqw_op(win,sqw_opfunc,pars,varargin{:});
    end
end
end
