function wout = cut_single(w, tag_proj, targ_axes, keep_pix, outfile)
%%CUT_SINGLE Perform a cut on a single sqw object
%
% Input:
% ------
% w           The sqw object to take a cut from.
% tag_proj    A `projection` object, defining the projection of the cut.
% targ_axes   `axes_block` object defining the ranges, binning and geometry
%             of the target cut
%
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

% Accumulate image and pixel data for cut
[s, e, npix, pix_out, pix_comb_info] = cut_accumulate_data_( ...
    w, tag_proj,targ_axes,keep_pix, log_level, return_cut ...
    );
% acutal_img_range left here for debugging purposes
%
if ~isempty(pix_comb_info) && isa(pix_comb_info, 'pix_combine_info')
    % Make sure we clean up temp files. If they were generated, they were 
    % done already
    cleanup = onCleanup(@() clean_up_tmp_files(pix_comb_info));
end


% Compile the accumulated cut and projection data into a data_sqw_dnd object
data_out = compile_sqw_data(...
    targ_axes, tag_proj, s, e, npix, pix_out,pix_comb_info, keep_pix);

% Assign the new data_sqw_dnd object to the output SQW object, or create a new
% dnd.
if keep_pix
    wout = sqw();
    wout.main_header = w.main_header;
    wout.experiment_info = w.experiment_info;
    wout.detpar = w.detpar;
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



% -----------------------------------------------------------------------------
function data_out = compile_sqw_data(targ_axes, proj, s, e, npix, pix_out, ...
    pix_comb_info, keep_pix)
%
data_str = proj.compart_struct;
data_str.s = s;
data_str.e = e;
data_str.npix = npix;
data_str.img_db_range = targ_axes.get_binning_range();

data_out = data_sqw_dnd(targ_axes,data_str);



if keep_pix
    if ~isempty(pix_comb_info) && isa(pix_comb_info, 'pix_combine_info')
        % If pix_comb_info is not empty then we've been working with temp files
        % for pixels and normal sqw object is not returned. Pixels have been
        % combined on disk earlier.
        data_out.pix = []; % TODO: Should think more about what we may want
        % to return in this situation
    else
        data_out.pix = pix_out;
    end
else
    data_out.pix = PixelData();
end


function clean_up_tmp_files(pix_comb_info)
% Manually clean-up temporary files created by a pix_combine_info object
for i = 1:numel(pix_comb_info.infiles)
    tmp_fpath = pix_comb_info.infiles{i};
    delete(tmp_fpath);
end
