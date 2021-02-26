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
return_cut = nargout > 0;

wout = copy(w, 'exclude_pix', true);

% Get bin boundaries
[ ...
    ubins.integration_axis_idx, ...
    ubins.integration_range, ...
    ubins.plot_ax_idx, ...
    ubins.plot_ax_bounds, ...
    ubins.img_range ...
    ] = proj.calc_transf_img_bins(w.data.img_range, pbin, pin, en);

% Update projection with binning
proj = proj.set_proj_binning( ...
    ubins.img_range, ...
    ubins.plot_ax_idx, ...
    ubins.integration_axis_idx, ...
    ubins.plot_ax_bounds ...
    );

% Accumulate image and pixel data for cut
[s, e, npix, pix_out, img_range, pix_comb_info] = cut_accumulate_data_( ...
    w, proj, keep_pix, log_level, return_cut ...
    );
if ~isempty(pix_comb_info) && isa(pix_comb_info, 'pix_combine_info')
    % Make sure we clean up temp files
    cleanup = onCleanup(@() clean_up_tmp_files(pix_comb_info));
end

% Compile the accumulated cut and projection data into a data_sqw_dnd object
data_out = compile_sqw_data(...
    w.data, proj, s, e, npix, pix_out,pix_comb_info, img_range, ...
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
        save(wout, outfile);
    catch ME
        warning('CUT_SQW:io_error', ...
            'Error writing to file ''%s''.\n%s: %s', ...
            outfile, ME.identifier, ME.message);
    end
end

end  % function


% -----------------------------------------------------------------------------
function data_out = compile_sqw_data(data, proj, s, e, npix, pix_out, ...
    pix_comb_info, img_range, ubins, keep_pix)
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
data_out.img_range = img_range;

if keep_pix
    % If pix_comb_info is not empty then we've been working with temp files
    % for pixels. We can replace the PixelData object that's normally in
    % sqw.data with this pix_combine_info object.
    % When the object is passed to 'put_sqw' (it's saved), 'put_sqw' will
    % combine the linked tmp files into the new sqw file.
    if ~isempty(pix_comb_info) && isa(pix_comb_info, 'pix_combine_info')
        data_out.pix = pix_comb_info;
    else
        data_out.pix = pix_out;
    end
end
end


function clean_up_tmp_files(pix_comb_info)
% Manually clean-up temporary files created by a pix_combine_info object
for i = 1:numel(pix_comb_info.infiles)
    tmp_fpath = pix_comb_info.infiles{i};
    delete(tmp_fpath);
end
end
