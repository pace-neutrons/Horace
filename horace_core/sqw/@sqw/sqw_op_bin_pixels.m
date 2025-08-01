function wout = sqw_op_bin_pixels(obj, sqwop_func, pars, varargin)
% Perform an operation or set of operations over pixels defined
% by user-provided sqwop_func. Unlike cut, the operation is performed
% within whole input sqw object piexls range and data which do not
%
%
%   >> wout = sqw_op_bin_pixels(obj, sqwfunc, p)
%      this form of call is equivalent to:
%   >> wout = sqw_op_bin_pixels(obj, sqwfunc, p, [], [], [], [])
%   >> wout = sqw_op_bin_pixels(obj, sqwfunc, p, p1_bin, p2_bin, p3_bin, p4_bin)
%   >> wout = sqw_op_bin_pixels(obj, sqwfunc, p, proj, p1_bin, p2_bin, p3_bin, p4_bin)
%
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
%          --  Handle to function that performs operation.
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
%  combine with true/false value folloving key or option '-combine'
%               if true or option '-combine' present, input sqw objects are
%               treated as parts of a single sqw object and the result is
%               build from the image of the first object, pixels of all
%               objects in input list and input binning parameters.
%
%
% Output:
% =======
%   wout     If `filebacked` is false, an sqw object or array of sqw objects
%            depending on input and algorithm control options.
%            If `filebacked` is true, a file path or cell array of file paths.
%            Output argument must be specified if `outfile` not given.
%
%==========================================================================
is_key = cellfun(@(x)istext(x),varargin);
if any(is_key)
    argi = varargin(~is_key);
else
    argi = varargin;
end
if numel(argi)<obj(1).data.NUM_DIMS % not very reliable but if even combine,
    % option is selected the main object for combine comes from the first
    % object and everything else can be considered binning. Now it works
    % but if something changes in a future this have to be reconsidered and
    % arguments analyzed in more details
    binning = cell(1,obj(1).data.NUM_DIMS);
    argi = [binning(:);argi(:)];
end
%
% Set up new projection properties, related to lattice. This together with
% projection inputs defines pixels-to-image transformation.
return_cut = nargout > 0;
[targ_proj, pbin, sym, opt] = SQWDnDBase.process_and_validate_cut_inputs(...
    obj(1),return_cut, argi{:});
if numel(sym)>1 || ~isa(sym{1},'SymopIdentity')
    error('HORACE:sqw_op_bin_pixels:not_implemented',[ ...
        'sqw_op_bin_pixels does not yet accepts Symop parameters.\n' ...
        'Add necessary SymOp to custom operation yourself'])
end

[targ_ax_block, targ_proj] = obj(1).define_target_axes_block(targ_proj, pbin{1}, sym);


argi = varargin(is_key);
[sqwop_func, pars, opts] = parse_eval_args(obj(1), sqwop_func, pars, argi{:});
if ~opt.keep_pix
    opts.nopix = true;
end

opt = rmfield(opt,{'keep_pix','outfile'});
opt_names = fieldnames(opt);
for i=1:numel(opt_names)
    opts.(opt_names{i})= opt.(opt_names{i});
end

if isempty(opts.outfile) || (isscalar(opts.outfile) && isempty(opts.outfile{1})) || opts.filebacked
    % Make sure we have exactly one output argument if no outfile is specified,
    % otherwise this function would do nothing.
    % Even in filebacked mode, if no outfile is given, a random one is
    % generated but will be destroyed after completeon. 
    % This is not much use to a user if it's not returned.
    if nargout ~=1
        error('HORACE:sqw_op_bin_pixels:invalid_argument',[ ...
            'This method request single output argument unless output filename to save result is specified.\n' ...
            'Filename is missing and got: %d output argumets'], ...
            nargout)
    end
end
if  opts.average
    error('HORACE:sqw_op_bin_pixels:not_implemented', [ ...
        '"-average" option is not currently implemented for sqw_op_bin_pixels.' ...
        'Contact HoraceHelp@stfc.ac.uk if you really need it implemented which the explanation of its meaning in your case'])
end
% if test_input_parsing option provided among input keys, we are testing input
% parameters parsing.
if opts.combine
    win=check_and_prepare_combine(obj);
else
    win = copy(obj);
end
if opts.test_input_parsing
    wout = opts;
    wout.targ_proj     = targ_proj;
    wout.targ_ax_block = targ_ax_block;
    wout.input_objects = win;
    % return input parameters without processing them
    return
end

wout = cell(1,numel(win));
for i=1:numel(win)
    wout{i} = sqw_op_bin_pix_single_(win(i),sqwop_func,pars,targ_ax_block,targ_proj,opts,i);
end
wout = [wout{:}];

end

%--------------------------------------------------------------------------
function wout=check_and_prepare_combine(win)
% Prepare input object for pixel combining
wout = copy(win(1));
if isscalar(win)
    return
end
n_inputs = numel(win);
% 
pix   = cell(1,n_inputs);
npix  = zeros(1,n_inputs);
exper = cell(1,n_inputs);
%
pix{1}   = wout.pix;
exper{1} = wout.experiment_info;
npix(1)  = wout.pix.num_pixels;
for i=2:n_inputs
    pix{i}   = win(i).pix;
    npix(i)  = win(i).pix.num_pixels;
    exper{i} = win(i).experiment_info;
end
% Build target output sqw object containing combine information
% and other sqw object information on the basis of first sqw object
pix_all = pixobj_combine_info(pix,num2cell(npix));
wout.data.do_check_combo_arg = false;
wout.data.npix = npix;
wout.data.s = zeros(1,numel(npix));
wout.data.e = zeros(1,numel(npix));
wout.experiment_info = exper{1}.combine_experiments(exper(2:end),true,true);
wout.pix = pix_all;
wout.data.do_check_combo_arg = true;

end
