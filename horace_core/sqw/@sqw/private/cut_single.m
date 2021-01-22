function wout = cut_single(w, proj, pbin, pin, en, keep_pix, outfile)
%%CUT_SINGLE Perform a cut on a single sqw object
%
% Input:
% ------
% w           The sqw object to take a cut from.
% proj        A `projection` object, defining the projection of the cut.
% pbin        The binning along each projection axis of the cut (cell array).
%             See p1_bin, p2_bin etc. in sqw/cut.
% pin         The binning of the input sqw object (cell array).
% en          Energy bins of input sqw header average (double).
% keep_pix    True if pixel information is to be retained in cut, else false.
% outfile     The output file to write the cut to, empty if cut is not to be
%             written to file (char).
%
% Output:
% -------
% wout       The output cut. If keep_pix is true this will be an SQW object,
%            else it will be DnD object.
%            This output argument can be omitted if `outfile` is specified.
%

% Rework of legacy function cut_sqw_main_single

DND_CONSTRUCTORS = {@d0d, @d1d, @d2d, @d3d, @d4d};
log_level = get(hor_config, 'log_level');

wout = copy(w, 'exclude_pix', true);

% Get bin boundaries
[ ...
    ubins.integration_axis_idx, ...
    ubins.integration_range, ...
    ubins.plot_ax_idx, ...
    ubins.plot_ax_bounds, ...
    ubins.urange ...
] = proj.calc_ubins(w.data.urange, pbin, pin, en);

% Update projection with binning
proj = proj.set_proj_binning( ...
    ubins.urange, ...
    ubins.plot_ax_idx, ...
    ubins.integration_axis_idx, ...
    ubins.plot_ax_bounds ...
);

% Accumulate image and pixel data for cut
[s, e, npix, pix_out, urange_pix] = cut_accumulate_data_(w, proj, keep_pix, log_level);

% Compile the accumulated cut and projection data into a data_sqw_dnd object
data_out = compile_sqw_data(w.data, proj, s, e, npix, pix_out, urange_pix, ...
                            ubins, keep_pix);

% Assign the new data_sqw_dnd object to the output SQW object, or create a new
% dnd.
if keep_pix
    wout.data = data_out;
else
    dnd_constructor = DND_CONSTRUCTORS{numel(data_out.pax) + 1};
    wout = dnd_constructor(data_out);
end

% Write result to file if necessary
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
function save_sqw(sqw_obj, file_path)
    loader = sqw_formats_factory.instance().get_pref_access();
    loader = loader.init(sqw_obj, file_path);
    loader.put_sqw();
    loader.delete();
end


function data_out = compile_sqw_data(data, proj, s, e, npix, pix_out, ...
                                     urange_pix, ubins, keep_pix)
    ppax = ubins.plot_ax_bounds(1:length(ubins.plot_ax_idx));
    if isempty(ppax)
        nbin_as_size = [1, 1];
    elseif length(ppax) == 1
        nbin_as_size = [length(ppax{1}) - 1, 1];
    else
        nbin_as_size = cellfun(@(nd) length(nd) - 1, ppax);
    end

    data_out = data;
    data_out.s = reshape(s, nbin_as_size);
    data_out.e = reshape(e, nbin_as_size);
    data_out.npix = reshape(npix, nbin_as_size);

    [ ...
        data_out.uoffset, ...
        data_out.ulabel, ...
        data_out.dax, ...
        data_out.u_to_rlu, ...
        data_out.ulen, ...
        data_out.axis_caption ...
    ] = proj.get_proj_param(data, ubins.plot_ax_idx);

    data_out.iax = ubins.integration_axis_idx;
    data_out.iint = ubins.integration_range;
    data_out.pax = ubins.plot_ax_idx;
    data_out.p = ubins.plot_ax_bounds;

    if keep_pix
        data_out.urange = urange_pix;
        data_out.pix = pix_out;
    end
end
