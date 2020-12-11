function wout = cut(obj, varargin)
%%CUT
%
wout = copy(obj);

ndims_source = numel(wout(1).data.pax);
return_cut = true;

[ok, mess, ~, proj, pbin, args, opt] = cut_sqw_check_input_args(obj, ndims_source, return_cut, varargin{:});
if ~ok
    error ('CUT_SQW:invalid_arguments', mess)
end

% Ensure there are no excess input arguments
if numel(args)~=0
    error ('CUT_SQW:invalid_arguments', 'Check the number and type of input arguments')
end

% Process projection
[proj, pbin, ~, pin, en] = update_projection_bins(proj, wout, pbin);

% TODO: add loop here when cutting more than one sqw
%   get size of array of cuts
%   get pbins for cuts
%   allocate array of sqw objects to output


%% Start: cut_sqw_main_single -------------------------------------------------

bounds = get_bin_boundaries(proj, wout.data.urange, pbin, pin, en);
proj = proj.set_proj_binning( ...
    bounds.urange, ...
    bounds.plot_ax_idx, ...
    bounds.integration_axis_idx, ...
    bounds.plot_ax_bounds ...
);
[bin_starts, bin_ends] = proj.get_nbin_range(wout.data.npix);

targ_pax = proj.target_pax;
targ_nbin = proj.target_nbin;


%% Start: cut_data_from_array -------------------------------------------------

% Pre-allocate image data
nbin_as_size = get_nbin_as_size(targ_nbin);
s = zeros(nbin_as_size);
e = zeros(nbin_as_size);
npix = zeros(nbin_as_size);
urange_step_pix = [Inf(1, 4); -Inf(1, 4)];

% Get pixels that will likely contribute to the cut
pix_indices = get_values_in_ranges(bin_starts, bin_ends);

iter = 1;
block_size = wout.data.pix.base_page_size;
pix_retained = cell(1, ceil(numel(pix_indices)/block_size));
pix_ix_retained = cell(1, ceil(numel(pix_indices)/block_size));
for block_start = 1:block_size:numel(pix_indices)
    block_end = min(block_start + block_size - 1, numel(pix_indices));
    candidate_pix = wout.data.pix.get_pixels(pix_indices(block_start:block_end));

    if get(hor_config, 'log_level') >= 0
        fprintf(['Step %3d of %3d; Have read data for %d pixels -- ' ...
                 'now processing data...'], iter, numel(pix_retained), ...
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
            opt.keep_pix, ...
            candidate_pix, ...
            proj, ...
            targ_pax ...
    );

    if get(hor_config, 'log_level') >= 0
        fprintf(' ----->  retained  %d pixels\n',del_npix_retain);
    end

    %% Continue: cut_data_from_array ----------------------------------------------

    if opt.keep_pix
        pix = candidate_pix.get_pixels(ok);
        pix_retained{iter} = pix;
        pix_ix_retained{iter} = ix;
    end

    iter = iter + 1;

end  % loop over pixel blocks

if opt.keep_pix
    pix_out = sort_pix(pix_retained, pix_ix_retained, npix);
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
data_out = wout.data;
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
] = proj.get_proj_param(wout.data, bounds.plot_ax_idx);

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

if opt.keep_pix
    data_out.urange = urange_pix;
    data_out.pix = pix_out;

    wout.data = data_out;
else
    switch numel(data_out.pax)
    case 0
        wout = d0d(data_out);
    case 1
        wout = d1d(data_out);
    case 2
        wout = d2d(data_out);
    case 3
        wout = d3d(data_out);
    case 4
        wout = d4d(data_out);
    otherwise
        error('SQW:cut', ...
              ['data_sqw_dnd has invalid number of projection axis.\n' ...
               '''pax'' must be integer in [0, 4], found ''%d'''], data_out.pax)
    end
end


end  % function


% -----------------------------------------------------------------------------
function [proj, pbin, num_dims, pin, en] = update_projection_bins( ...
        proj, wout, pbin)
    % header_av = header_average(wout.header);
    header_av = testgateway(sqw, 'header_average', wout.header);
    [proj, pbin, num_dims, pin, en] = proj.update_pbins( ...
            header_av, wout.data, pbin);
end


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


function out = get_values_in_ranges(range_starts, range_ends)
    % Get an array containing the values between the given ranges
    % e.g.
    %   >> range_starts = [1, 15, 12]
    %   >> range_ends = [4, 17, 14]
    %   >> get_values_in_range(range_starts, range_ends)
    %       ans = [1, 2, 3, 4, 15, 16, 17, 12, 13, 14]

    % Find the indexes of the boundaries of each range
    range_bounds_idxs = cumsum([1; range_ends(:) - range_starts(:) + 1]);
    z = ones(range_bounds_idxs(end) - 1, 1);
    % Insert size of the difference between boundaries in each boundary index
    z(range_bounds_idxs(1:end - 1)) = [ ...
        range_starts(1); range_starts(2:end) - range_ends(1:end - 1) ...
    ];
    % Take a cumulative sum
    out = cumsum(z);
end
