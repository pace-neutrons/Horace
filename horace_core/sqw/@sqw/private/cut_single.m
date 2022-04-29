function [wout,log_info] = cut_single(w, tag_proj, targ_axes, keep_pix, outfile,log_level)
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
% log_level   verbosity of the cut progress report. Taken from
%             hor_config.log_level and propagated through the parameters to
%             avoid subsequent calls to hor_config.
%
% Output:
% -------
% wout       The output cut. If keep_pix is true this will be an SQW object,
%            else it will be DnD object.
%            This output argument can be omitted if `outfile` is specified.
%

% Rework of legacy function cut_sqw_main_single

DND_CONSTRUCTORS = {@d0d, @d1d, @d2d, @d3d, @d4d};
return_cut = nargout > 0;

% Accumulate image and pixel data for cut
[s, e, npix, pix_out,runid_contributed] = cut_accumulate_data_( ...
    w, tag_proj,targ_axes,keep_pix, log_level, return_cut);
if isa(pix_out, 'pix_combine_info')
    % Make sure we clean up temp files.
    cleanup = onCleanup(@() clean_up_tmp_files(pix_out));
end


% Compile the accumulated cut and projection data into a data_sqw_dnd object
data_out = compile_sqw_data(...
    targ_axes, tag_proj, s, e, npix, pix_out,keep_pix);

% Assign the new data_sqw_dnd object to the output SQW object, or create a new
% dnd.
if keep_pix
    wout = sqw();
    wout.main_header = w.main_header;
    wout.detpar = w.detpar;
    wout.data   = data_out;

    if isempty(runid_contributed) % Empty cut
        exp_info = Experiment();
    else
        % old stored objects, which do not contain correctly defind runid map
        % compartibility operation.
        % TODO: Should be check for old file and after that -- this code.
        head_runid = w.experiment_info.expdata.get_run_ids();
        if ~any(ismember(runid_contributed,head_runid))
            % some old file conains runid, which has been
            % recalculated from 1 to n_headers on pixels but have not been
            % stored in runid map and in headers.
            % assuming that runid-s indeed been redefined this way, we can 
            % restore their run-ids in experiment_info
            id = 1:w.experiment_info.n_runs;
            w.experiment_info.expdata.runid_map = id;
        end
        exp_info = w.experiment_info.get_subobj(runid_contributed);
    end
    %
    wout.main_header.nfiles  = exp_info.n_runs;
    wout.experiment_info = exp_info;

else
    dnd_constructor = DND_CONSTRUCTORS{numel(data_out.pax) + 1};
    wout = dnd_constructor(data_out);
end

% Write result to file if necessary
if exist('outfile', 'var') && ~isempty(outfile)
    if log_level >= 0
        disp(['*** Writing cut to output file ', outfile, '...']);
    end
    try
        save(wout, outfile);
    catch ME
        warning('HORACE:cut_sqw:io_error', ...
            'Error writing to file ''%s''.\n%s: %s', ...
            outfile, ME.identifier, ME.message);
    end
end


% -----------------------------------------------------------------------------
function data_out = compile_sqw_data(targ_axes, proj, s, e, npix, pix_out, ...
    keep_pix)
%
data_str = proj.compart_struct;
data_str.s = s;
data_str.e = e;
data_str.npix = npix;

data_out = data_sqw_dnd(targ_axes,data_str);


if keep_pix
    data_out.pix = pix_out;
else
    data_out.pix = PixelData();
end


function clean_up_tmp_files(pix_comb_info)
% Manually clean-up temporary files created by a pix_combine_info object
for i = 1:numel(pix_comb_info.infiles)
    tmp_fpath = pix_comb_info.infiles{i};
    delete(tmp_fpath);
end
