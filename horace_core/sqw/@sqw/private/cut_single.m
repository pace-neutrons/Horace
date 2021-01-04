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

% Accumulate image and pixel data for cut
[s, e, npix, pix_out, urange_pix] = accumulate_cut_data_(w, proj, keep_pix, log_level);

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


function save_sqw(sqw_obj, file_path)
    loader = sqw_formats_factory.instance().get_pref_access();
    loader = loader.init(sqw_obj, file_path);
    loader.put_sqw();
    loader.delete();
end
