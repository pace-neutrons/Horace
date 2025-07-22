function wout = sqw_op(win, sqw_opfunc, pars, varargin)
% Apply operation or sequence of operations over input sqw files or sqw
% objects packed in input cellarray.
%
% The operations act on pixels and are defined in user provided
% sqw_opfunc which should accept PageOp_sqw_op object as first argument
%
%   >> wout = sqw_op(win, sqwfunc, p)
%   >> wout = sqw_op(__,PageOp_processor)
%   >> sqw_op(__, 'outfile', outfile, 'filebacked', true)
%   >> wout = sqw_op(__, '-filebacked')% 
% 
% Input:
% ------
%   win    --  Dataset file (or cell array) that provides filenames or sqw
%              objects serving as the source of coordinates and other
%              information for sqwop_func:
%
% sqwop_func
%          --  Handle to function that performs operation
%   pars   --  Cellarray of arguments needed by the function.
%              The function would have a form
%              sqwop_func(PageOp_sqw_eval_obj_instance,pars{:});
%
% Optional:
% ------------------
% PageOp_processor
%          -- the instance of a class-child of PageOp_sqw_op class, which
%             provides additional functionality to PageOp_sqw_op operation.
% 'outfile'
%          -- the key, followed by the name of sqw file to store result in.
%

% Returns:
%
% wout      -- array of sqw objects or filebacked sqw objects-- the results
%              of applying sqw_opfunc to them.
%
%
[n_inputs,ldrs,sqw_obj] = init_sqw_obj_from_file_for_sqw_op_(win);
wout = cell(1,n_inputs);
for i=1:n_inputs
    if sqw_obj(i)
        win = ldrs{i};
    else
        win = sqw(ldrs{i});
    end
    if nargout > 0
        wout{i} = sqw_op(win,sqw_opfunc,pars,varargin{:});
    end
end
wout = [wout{:}];
end
