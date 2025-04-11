function wout = sqw_op_bin_pixels(win, sqw_opfunc, pars, varargin)
% Apply operation or sequence of operations over input sqw files or sqw
% objects packed in input cellarray.
%
% The operations act on pixels and are defined in user provided
% sqw_opfunc which should accept PageOp_sqw_op object as first argument
%   >> wout = sqw_op_bin_pixels(win, sqwfunc, p)
%      this form of call is equivalent to:
%   >> wout = sqw_op_bin_pixels(win, sqwfunc, p, [], [], [], [])
%   >> wout = sqw_op_bin_pixels(win, sqwfunc, p, p1_bin, p2_bin, p3_bin, p4_bin)
%   >> wout = sqw_op_bin_pixels(win, sqwfunc, p, proj, p1_bin, p2_bin, p3_bin, p4_bin)
%
%   >> sqw_op(__, 'outfile', outfile, 'filebacked', true)
%   >> wout = sqw_op(__, '-filebacked')
%
% Input:
% ======
%   obj    --   sqw object (or array of objects) used
%               as the source of coordinates and other information for
%               sqwop_func
% sqwop_func
%          --  Handle to function that performs operation
%   pars   --  Cellarray of arguments needed by the function.
%              The function would have a form
%              sqwop_func(PageOp_sqw_eval_obj_instance,pars{:});
% Optional:
% =========
% Binning parameters: -- the input similar to the inputs of cut algorithm
% -------------------    defining target projection binning. Unlike 
%   proj           instance of aProjectionBase class (line_proj by default)
%                  which describes the target coordinate system of the cut
%                  or Data structure containing the projection class fields,
%                  (names and its values)
%                  (type >> help line_proj   for details)
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%           - [] or ''          Plot axis: use bin boundaries of input data
%           - [pstep]           Plot axis: sets step size; plot limits
%                               taken from the extent of the data. If pstep
%                               is 0, step is also taken from input data
%                               (equivalent to [])
%           - [plo, phi]        Integration axis: range of integration
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centres
%                              and step size
%                              For example, [106, 4, 116] will define a plot
%                              axis with bin edges 104-108, 108-112, 112-116.
%                              if step is 0,
%           - [plo, rdiff, phi, rwidth]
%                                Integration axis: minimum range centre,
%                                distance between range centres, maximum range
%                                centre, range size for each cut.
%                                When using this syntax, an array of cuts is
%                                outputted. The number of cuts produced will
%                                be the number of rdiff sized steps between plo
%                                and phi; phi will be automatically increased
%                                such that rdiff divides phi - plo.
%                                For example, [106, 4, 113, 2] defines the
%                                integration range for three cuts, the first
%                                cut integrates the axis over 105-107, the
%                                second over 109-111 and the third 113-115.
%
%   p4_bin          Binning along the energy axis:
%           - [] or ''          Plot axis: use bin boundaries of input data
%           - [pstep]           Plot axis: sets step size; plot limits
%                              taken from the extent of the data.
%                               If pstep=0 then use bin size of the first
%                              spe file and synchronize the output bin
%                              boundaries with those boundaries. The overall
%                              range is chosen to ensure that the energy
%                              range of the input data is contained within
%                              the bin boundaries.
%           - [plo, phi]        Integration axis: range of integration
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centres
%                              and step size.
%                               If pstep=0 then use bin size of the first
%                              spe file and synchronize the output bin
%                              boundaries with the reference boundaries.
%                              The overall range is chosen to ensure that
%                              the energy range plo to phi is contained
%                              within the bin boundaries.
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
% =======
%   wout     If `filebacked` is false, an sqw object or array of sqw objects.
%             If `filebacked` is true, a file path or cell array of file paths.
%              Output argument must be specified if `outfile` not given.
%


[n_inputs,ldrs,sqw_obj,wout] = init_sqw_obj_from_file_for_sqw_op_(win);
for i=1:n_inputs
    if sqw_obj(i)
        win = ldrs{i};
    else
        win = sqw(ldrs{i});
    end
    if nargout > 0
        wout(i) = sqw_op_bin_pixels(win,sqw_opfunc,pars,varargin{:});
    end
end
end

