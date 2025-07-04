function wout = cut_single_(w, targ_proj, targ_axes, opt, log_level, sym)
%%CUT_SINGLE Perform a cut on a single sqw object
%
% Input:
% ------
% w           The sqw object to take a cut from.
% targ_proj    A `projection` object, defining the projection of the cut.
% targ_axes   `AxesBlockBase` object defining the ranges, binning and geometry
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
return_cut  =  nargout>0;
%
outfile_specified = isfield(opt, 'outfile') && ~isempty(opt.outfile);

% Accumulate image and pixel data for cut
[s, e, npix, pix_out,runid_contributed] = cut_accumulate_data_( ...
    w, targ_proj, targ_axes, opt.keep_pix, log_level, sym);


if isa(pix_out, 'MultipixBase')
    filebacked_object = true;
    % Make sure we clean up temp files.
    cleanup = onCleanup(@() clean_up_tmp_files(pix_out));
    if ~outfile_specified
        opt.outfile = build_tmp_file_name(w.full_filename);
    end
else
    filebacked_object = false;
end


% Compile the accumulated cut and projection data into a data_sqw_dnd object
data_out = compile_sqw_data(...
    targ_axes, targ_proj, s, e, npix, pix_out, opt.keep_pix);

% Assign the new data_sqw_dnd object to the output SQW object, or create a new
% dnd.
if opt.keep_pix
    wout = sqw();
    wout.main_header = w.main_header;
    % NB detpar is no longer copied as detpar just exposes the detector_arrays
    % already in experiment_info
    wout.data   = data_out.data;
    wout.pix  = data_out.pix;

    if isempty(runid_contributed) % Empty cut
        exp_info = Experiment();
    else
        if ~w.main_header.creation_date_defined
            % old stored objects, which do not contain correctly defined runid map
            % compatibility operation.
            head_runid = w.experiment_info.expdata.get_run_ids();
            if  any(~ismember(runid_contributed,head_runid))
                % some old file contains runid, which has been
                % recalculated from 1 to n_headers on pixels but have not been
                % stored in runid map and headers.
                % assuming that runid-s indeed been redefined this way, we can
                % restore their run-ids in experiment_info
                id = 1:w.experiment_info.n_runs;
                w.experiment_info.runid_map = id;
            end
        end
        exp_info = w.experiment_info.get_subobj(runid_contributed);
    end

    wout.experiment_info = exp_info;
    wout.main_header.nfiles  = exp_info.n_runs;
    % set new cut object creation date defined and equal to now if the
    % resulting cut contributing runs number is smaller then the original
    % number
    if w.main_header.nfiles ~= wout.main_header.nfiles
        wout.main_header.creation_date = datetime('now');
    end
else
    % Should it be sqw without pixels? We may want to
    % do it if the result is an array of sqw cuts, some empty
    wout = data_out.data;
end


if log_level >= 0 && outfile_specified
    disp(['*** Writing cut to output file ', opt.outfile, '...']);
end
% Write result to file if necessary
if filebacked_object % this is the only filebacked object one may
    % produce. Otherwise it is memorybased
    hpc = hpc_config;
    hc = hor_config;

    use_mex = hc.use_mex && strcmp(hpc.combine_sqw_using,'mex_code');
    page_op         = PageOp_join_sqw;
    page_op.outfile = opt.outfile;
    [page_op,wout]  = page_op.init(wout,[],use_mex);
    % TODO: Re #1320 do not load result in memory and do not initilize
    % filebacked operations if it is not requested
    % if ~return_cut; apply_without wout; else; end
    wout              = sqw.apply_op(wout,page_op);
else % memory-based object
    if outfile_specified
        % TODO: Re #1320 save should return sqw object if requested
        % this currently does not work properly for filebacked objects
        save(wout, opt.outfile);
        wout.full_filename = opt.outfile;
        [~,~,fe]= fileparts(opt.outfile);
        if strncmpi(fe,'.tmp',4)
            wout = wout.set_as_tmp_obj();
        end
    end
end

end
%
function data_out = compile_sqw_data(targ_axes, proj, s, e, npix, pix_out, ...
    keep_pix)

data_out.data = DnDBase.dnd(targ_axes(1),proj(1),s,e,npix);

if keep_pix
    data_out.pix = pix_out;
else
    data_out.pix = PixelDataBase.create();
end
end
