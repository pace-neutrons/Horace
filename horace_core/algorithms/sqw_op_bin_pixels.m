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
%   filebacked with true/false value following key or option '-filebacked'
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
%              Output argument must be specified if `outfile` not given.


[n_inputs,sqw_or_ldrs,is_sqw_obj] = init_sqw_obj_from_file_for_sqw_op_(win);

[sqw_or_ldr,is_sqw,argi] = check_and_prepare_combine(sqw_or_ldrs,is_sqw_obj,n_inputs,varargin{:});
%
n_inputs = numel(is_sqw); % number of input object may change due to combining
% process input dataset(s)
wout = cell(1,n_inputs);
for i=1:n_inputs
    if is_sqw_obj(i)
        win = sqw_or_ldr{i};
    else
        win = sqw(sqw_or_ldr{i});
    end
    if nargout>0
        wout{i} = sqw_op_bin_pixels(win,sqw_opfunc,pars,argi{:});
    else
        sqw_op_bin_pixels(win,sqw_opfunc,pars,argi{:});
    end
end
wout = [wout{:}];
if isstruct(wout) && wout.test_input_parsing % This is testing for input
    % arguments so we add processed
    % or not processed input objects to output
    wout.input_ldrs = sqw_or_ldr;
end
end
%--------------------------------------------------------------------------
function [wout,is_sqw,argi]=check_and_prepare_combine(ldr_or_sqw,is_sqw,n_inputs,varargin)
% Process combine arguments and extract them from input stream
combine_inputs = false;
is_combine = cellfun(@check_combine_key,varargin);
if any(is_combine)
    is_key = is_combine>0;
    if sum(is_key)>1
        error('HORACE:sqw_op_bin_pixels:invalid_argument', ...
            'More then one input is interpreted as "combine" key. They are: %s', ...
            disp2str(varargin(is_key)));
    end
    if is_combine(is_key) == 1 % key only syntaxis
        combine_inputs = true;
        argi = varargin(~logical(is_combine));
    elseif is_combine(is_key) == 2
        id = find(is_combine); %key-value syntaxis;
        combine_inputs = logical(varargin{id+1});
        is_combine(id)   = 1;
        is_combine(id+1) = 1;
        argi = varargin(~logical(is_combine));
    else % no combine keys -- can not happen here. They have already indentified above
        error('HORACE:sqw_op_bin_pixels:runtime_error', ...
            'Unexpected combine_key value. Its a bug. Contact developers at HoraceHelp@stfc.ac.uk')
    end
else
    argi = varargin;
end

if combine_inputs && n_inputs > 1
    % Prepare pixel combine information gathered from all input
    % files/datasets
    if is_sqw(1)
        wout = ldr_or_sqw{1};
    else
        wout = sqw(ldr_or_sqw{1});
    end
    % get access
    pix   = cell(1,n_inputs);
    exper = cell(1,n_inputs);        
    npix  = zeros(1,n_inputs);
    pix{1} = wout.pix;
    npix(1)= wout.pix.num_pixels;
    exper{1} = wout.experiment_info;
    for i=2:n_inputs
        if is_sqw(i)
            twin = ldr_or_sqw{i};
        else
            twin = sqw(ldr_or_sqw{i});
        end
        exper{i} = twn.experiment_info;
        pix{i} = twin.pix;
        npix(i)= twin.pix.num_pixels;
    end
    % Build target output sqw object containing combine information
    % and other sqw object information on the basis of first sqw object
    pix_all = pixobj_combine_info(pix,num2cell(npix));
    wout.data.do_check_combo_arg = false;
    wout.data.npix = npix;
    wout.data.s = zeros(1,numel(npix));
    wout.data.e = zeros(1,numel(npix));
    wout.pix = pix_all;
    wout.experiment_info = exper{1}.combine_experiments(exper(2:end),true,true);
    wout.data.do_check_combo_arg = true;
    is_sqw   = true; % single sqw object containing combine information
    wout = {wout};   % further code expects cellarray
else % no combine or combine ignored
    wout = ldr_or_sqw;
end
end


function is_comb = check_combine_key(x)
% check if combine key is present and return one if it is option and 2 if
% it is key-value pair
is_comb = 0;
if ~istext(x)
    return;
end
com_length = max(3,strlength(x));
if istext(x)
    if strncmp(x,'-',1)
        if strncmp(x,'-combine',com_length+1)
            is_comb = 1;
        end
    elseif strncmp(x,'combine',com_length)
        is_comb = 2;
    end
end
end
