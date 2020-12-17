function wout = cut_single(w, proj, pbin, pin, en, keep_pix, outfile)
%%CUT_SINGLE
%

% Add check that we can write to output file at beginning of algorithm

DND_CONSTRUCTORS = {@d0d, @d1d, @d2d, @d3d, @d4d};
log_level = get(hor_config, 'log_level');

wout = copy(w, 'exclude_pix', true);

% Get bin boundaries, projection and pix bin ranges
bounds = get_bin_boundaries(proj, w.data.urange, pbin, pin, en);
proj = proj.set_proj_binning( ...
    bounds.urange, ...
    bounds.plot_ax_idx, ...
    bounds.integration_axis_idx, ...
    bounds.plot_ax_bounds ...
);
[bin_starts, bin_ends] = proj.get_nbin_range(w.data.npix);

%% Start: cut_data_from_array -------------------------------------------------

% Pre-allocate image data
nbin_as_size = get_nbin_as_size(proj.target_nbin);
s = zeros(nbin_as_size);
e = zeros(nbin_as_size);
npix = zeros(nbin_as_size);
urange_step_pix = [Inf(1, 4); -Inf(1, 4)];

if ~isempty(bin_starts)

    % Get the cumulative sum of pixel bin sizes and work out how many
    % iterations we're going to need
    cum_bin_sizes = cumsum(bin_ends - bin_starts);
    block_size = w.data.pix.base_page_size;
    max_num_iters = ceil(cum_bin_sizes(end)/block_size);

    % Pre-allocate cell arrays to hold PixelData chunks
    pix_retained = cell(1, max_num_iters);
    pix_ix_retained = cell(1, max_num_iters);

    block_end_idx = 0;
    for iter = 1:max_num_iters
        block_start_idx = block_end_idx + 1;
        if block_start_idx > numel(cum_bin_sizes)
            % If start index has reached end of bin sizes, we've reached the end
            break
        end

        % Work out how many full bins we can load given we only want to load
        % a block_size number of pixels
        next_idx_end = find(cum_bin_sizes(block_start_idx:end) > block_size, 1);
        block_end_idx = block_end_idx + next_idx_end - 1;
        if isempty(block_end_idx)
            % There are less than block_size no. of pixels in the remaining bins
            block_end_idx = numel(cum_bin_sizes);
        end

        if block_start_idx > block_end_idx
            % Occurs where bin size greater than block size, just read in the
            % whole bin
            block_end_idx = block_start_idx;
            pix_assigned = bin_ends(block_end_idx) - bin_starts(block_start_idx);
        else
            pix_assigned = block_size;
        end

        % Subtract the number of pixels we've assigned from our cumulative sum
        cum_bin_sizes = cum_bin_sizes - pix_assigned;

        % Get pixels that will likely contribute to the cut
        candidate_pix = w.data.pix.get_pix_in_ranges( ...
            bin_starts(block_start_idx:block_end_idx), ...
            bin_ends(block_start_idx:block_end_idx) ...
        );

        if log_level >= 0
            fprintf(['Step %3d of maximum %3d; Have read data for %d pixels -- ' ...
                        'now processing data...'], iter, max_num_iters, ...
                    candidate_pix.num_pixels);
        end

        [ ...
            s, ...
            e, ...
            npix, ...
            urange_step_pix, ...
            del_npix_retain, ...
            ok, ...
            ix ...
        ] = cut_data_from_file_job.accumulate_cut( ...
                s, ...
                e, ...
                npix, ...
                urange_step_pix, ...
                keep_pix, ...
                candidate_pix, ...
                proj, ...
                proj.target_pax ...
        );

        if log_level >= 0
            fprintf(' ----->  retained  %d pixels\n', del_npix_retain);
        end

        %% Continue: cut_data_from_array ----------------------------------------------

        if keep_pix
            pix_retained{iter} = candidate_pix.get_pixels(ok);
            pix_ix_retained{iter} = ix;
        end

    end  % loop over pixel blocks

    if keep_pix
        pix_out = sort_pix(pix_retained, pix_ix_retained, npix);
    end
else
    pix_out = PixelData();

end
%% End: cut_data_from_array ---------------------------------------------------


%% Continue: cut_sqw_main_single ----------------------------------------------

% Convert range from steps to actual range with respect to output uoffset
urange_pix = urange_step_pix.*repmat(proj.usteps, [2, 1]) + repmat(proj.urange_offset, [2, 1]);

ppax = bounds.plot_ax_bounds(1:length(bounds.plot_ax_idx));
if isempty(ppax)
    nbin_as_size = [1, 1];
elseif length(ppax) == 1
    nbin_as_size = [length(ppax{1}) - 1, 1];
else
    nbin_as_size = cellfun(@(nd) length(nd) - 1, ppax);
end

% Prepare output data
data_out = w.data;
s = reshape(s, nbin_as_size);
e = reshape(e, nbin_as_size);
npix = reshape(npix, nbin_as_size);

[ ...
    data_out.uoffset, ...
    data_out.ulabel, ...
    data_out.dax, ...
    data_out.u_to_rlu, ...
    data_out.ulen, ...
    axis_caption ...
] = proj.get_proj_param(w.data, bounds.plot_ax_idx);

data_out.axis_caption = axis_caption;

data_out.iax = bounds.integration_axis_idx;
data_out.iint = bounds.integration_range;
data_out.pax = bounds.plot_ax_idx;
data_out.p = bounds.plot_ax_bounds;

data_out.s = s./npix;
data_out.e = e./(npix.^2);
data_out.npix = npix;
no_pix = (npix == 0);  % true where no pixels contribute to given bin
data_out.s(no_pix) = 0;
data_out.e(no_pix) = 0;

if keep_pix
    data_out.urange = urange_pix;
    data_out.pix = pix_out;

    wout.data = data_out;
else
    dnd_constructor = DND_CONSTRUCTORS{numel(data_out.pax) + 1};
    wout = dnd_constructor(data_out);
end

if exist('outfile', 'var') && ~isempty(outfile)
    if log_level >= 0
        disp(['Writing cut to output file ', outfile, '...']);
    end
    try
        save_sqw(wout, outfile);
    catch ME
        warning('CUT_SQW:io_error', ...
                'Error writing to file ''%s''.\n%s: %s', ...
                outfile, ME.identifier, ME.message);
    end
end

end  % function


% -----------------------------------------------------------------------------
function bounds = get_bin_boundaries(proj, urange, pbin, pin, en)
    [iax, iint, pax, p, urange] = proj.calc_ubins(urange, pbin, pin, en);
    bounds.integration_axis_idx = iax;
    bounds.integration_range = iint;
    bounds.plot_ax_bounds = p;
    bounds.plot_ax_idx = pax;
    bounds.urange = urange;
end


function nbin_as_size = get_nbin_as_size(nbin)
    % Output arrays for accumulated data
    % Note: Matlab silliness when one dimensional: MUST add an outer dimension
    % of unity. For 2D and higher, outer dimensions can always be assumed.
    % The problem with 1D is that e.g. zeros([5]) is not the same as
    % zeros([5,1]) whereas zeros([5,3]) is the same as zeros([5,3,1]).
    if isempty(nbin)
        nbin_as_size = [1, 1];
    elseif length(nbin) == 1
        nbin_as_size = [nbin, 1];
    else
        nbin_as_size = nbin;
    end
end


function save_sqw(sqw_obj, file_path)
    loader = sqw_formats_factory.instance().get_pref_access();
    loader = loader.init(sqw_obj, file_path);
    loader.put_sqw();
    loader.delete();
end
