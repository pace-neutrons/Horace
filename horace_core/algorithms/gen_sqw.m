function [tmp_file,grid_size,pix_range,varargout] = gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
    u, v, psi, omega, dpsi, gl, gs, varargin)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
% Normal use:
%   >> gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs)
%   >> gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, 'key1', 'key2'...)
%
% Optionally (before any keywords):
%   >> gen_sqw (..., instrument,   sample)    % instrument and sample information
%   >> gen_sqw (..., grid_size_in, pix_db_range_in) % grid size and range of data to retain
%   >> gen_sqw (..., grid_size_in, pix_db_range_in, instrument, sample)
%
%
% If want output diagnostics:
%   >> [tmp_file,grid_size,pix_db_range] = gen_sqw (...)
%
%
% Input: (in the following, nfile = number of spe files)
% ------
%   spe_file        Full file name of spe file - character string or cell array of
%                   character strings for more than one file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2, elastic=0    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
% Optional arguments:
%
%   grid_size_in    Scalar or row vector of grid dimensions
%                   Default if not given or [] is is [50,50,50,50]
%   pix_db_range_in Range of data grid for output as a 2x4 matrix:
%                              [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                   Default if not given or [] is the smallest hypercuboid that encloses the whole pixel range.
%                   calculated from the detector positions and min/max
%                   values of energy transfer
%   instrument      Structure or object containing instrument information [scalar or array length nfile]
%   sample          Structure or object containing sample geometry information [scalar or array length nfile]
%
%
% Optional keyword flags:
%
%   'replicate'     Build an sqw file with the same spe file being used as a data source
%                  more than once e.g. when making a background from an empty sample
%                  environment run.
%
%   'accumulate'    Accumulate data onto an existing sqw file, retaining the same binning.
%                  Any spe files that have already been included in the sqw file are ignored.
%                  Any spe files that do not yet exist are ignored.
%                   If the sqw file has not yet been created, use the input arguments to
%                  estimate the grid size. For this reason, the parameters efix, psi,
%                  omega, dpsi, gl, gs should be given for all planned runs.
%
%   'clean'         [Only valid if 'accumulate' is also present]. Delete the sqw file if
%                  it exists.
%   'tmp_only'     Debugging option. If selected, gen_sqw only generates
%                  tmp files but does not combine it together into final
%                  sqw file. These files can be then combined together into
%                  sqw file using write_nsqw_to_sqw algorithm. The
%                  hor_config.remove_tmp_files option's value is ignored
%                  when this parameter is selected.
%
%  'transform_sqw' Keyword, followed by the function handle to transform
%                  sqw object. The function should have the form:
%                  wout = f(win) where win is input sqw object and wout --
%                  the transformed one. For example f can symmetrize sqw file:
% i.e:
%   >> gen_sqw(...,...,...,'transform_sqw',@(x)(symmetrise_sqw(x,[0,1,0],[0,0,1],[0,0,0])))
%                  would symmetrize pixels of the generated sqw file by
%                  reflecting them in the plane specified by vectors
%                  [0,1,0], and [0,0,1] (see symmeterise_sqw for details)
% Output:
% --------
%   tmp_file        Cell array with list of temporary files created by this call to gen_sqw.
%                  If only one input spe file, then no temporary file created, and tmp_file
%                  is an empty cell array.
%   grid_size      Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   pix_range      The actual range of pixels (in crystal cartesian),
%                  contributing into sqw file. Different from pix_db_range_in
%                  as shows
%
%  parallel_cluster if job is executed in parallel and nargout >3, this
%                  variable would return the initialized instance of the
%                  job dispatcher, running a parallel job to continue

% T.G.Perring  14 August 2007
% T.G.Perring  19 March 2013   Massively updated, also includes functionality of accumulate_sqw

% *** Possible improvements
% - Cleverer choice of grid size on the basis of number of data points in the file


% Determine keyword arguments, if present
arglist=struct('replicate',0,'accumulate',0,'clean',0,'tmp_only',0,'time',0,...
    'transform_sqw',[]);
flags={'replicate','accumulate','clean','tmp_only'};
[args,opt,present] = parse_arguments(varargin,arglist,flags);

%Horrible hack (2nd if statement) because of shortcoming in the way
%parse_arguments is set up for mixtures of logical keywords and optional
%input arguments
if ~opt.accumulate
    if present.clean && opt.clean
        error('HORACE:gen_sqw:invalid_argument', ...
            'Invalid option ''clean'' unless also have option ''accumulate''')
    end
    if present.time && (exist(opt.time,'var') || ~isnumeric(opt.time) || opt.time~=0)
        error('HORACE:gen_sqw:invalid_argument', ...
            'Invalid option ''time'' unless also have option ''accumulate'' and/or a date-time vector following')
    end
end

if present.transform_sqw
    for i=1:numel(opt.transform_sqw)
        check_transf_input(opt.transform_sqw, i);
    end

    if numel(opt.transform_sqw)>1 && ...
       numel(opt.transform_sqw) ~= numel(psi)
            error('HORACE:gen_sqw:invalid_argument', ...
                  ['When more then one sqw file transformation is provided', ...
                   ' number of transformations should be equal to number of spe ',...
                   'files to transform\n.',...
                   ' In fact have %d files and %d transformations defined.'],...
                  numel(opt.transform_sqw),numel(psi))
    end
end

if nargout>3
    varargout{1} = [];
end

%If we are to run in 'time' mode, where execution waits for some period,
%then must do so here, because any later we check whether or not spe files
%exist.
if present.time
    if ~isnumeric(opt.time)
        error('HORACE:gen_sqw:invalid_argument', ...
            'Argument following option ''time'' must be vector of date-time format [yyyy,mm,dd,hh,mm,ss]')
    elseif numel(opt.time)~=6
        error('HORACE:gen_sqw:invalid_argument', ...
            'Argument following option ''time'' must be vector of date-time format [yyyy,mm,dd,hh,mm,ss]')
    end

    end_time=datenum(opt.time);
    time_now=now;

    if end_time<=time_now
        error('HORACE:gen_sqw:invalid_argument', ...
            'Date-time for accumulate_sqw to start is in the past');
    elseif (end_time-time_now) > 1
        disp('**************************************************************************************************')
        disp('***  WARNING: date-time specified for accumulate_sqw to start is more than 1 day in the future ***');
        disp('***  Hit Ctrl-C to abort and re-launch gen_sqw / accumulate_sqw                                ***');
        disp('**************************************************************************************************')
    else
        disp('**************************************************************************************************')
        disp('***  Waiting to accumulate data to sqw_file                                                    ***');
        disp(['***  Waiting until: ',num2str(opt.time(4)),'hr',num2str(opt.time(5)),...
            ', ',num2str(opt.time(3)),'-',num2str(opt.time(2)),'-',num2str(opt.time(1)),'              ***']);
        disp('**************************************************************************************************')
    end

    %time in seconds to wait:
    pause_sec=(end_time - time_now)*24*60*60;
    pause(pause_sec);
end


% Check file names are valid, and their existence or otherwise
require_spe_unique = ~opt.replicate;
require_spe_exist = ~opt.accumulate;
require_sqw_exist=false;

[spe_file, par_file, sqw_file, spe_exist, spe_unique, sqw_exist] = gen_sqw_check_files...
    (spe_file, par_file, sqw_file, require_spe_exist, require_spe_unique, require_sqw_exist);

n_all_spe_files=numel(spe_file);


% Set the status of flags for the three cases we must handle
% (One and only of the three cases below will be true, the others false.)
accumulate_old_sqw=false;   % true if want to accumulate spe data to an existing sqw file (not all spe data files need exist)
accumulate_new_sqw=false;   % true if want to accumulate spe data to a new sqw file (not all spe data files need exist)
use_partial_tmp = false;    % true to generate a combined sqw file during accumulate sqw using tmp files calculated at
% previous accumulation steps
log_level=...
    config_store.instance().get_value('herbert_config','log_level');
delete_tmp=...
    config_store.instance().get_value('hor_config','delete_tmp');
combine_algorithm =...
    config_store.instance().get_value('hpc_config','combine_sqw_using');

if opt.accumulate
    if sqw_exist && ~opt.clean  % accumulate onto an existing sqw file
        accumulate_old_sqw=true;
    else
        accumulate_new_sqw=true;
    end
    if ~strcmpi(combine_algorithm,'matlab') % use tmp rather than sqw file as source of
        opt.clean = true;                   % input data (works faster as parallel jobs are better balanced)
        use_partial_tmp = true;
    end
end


% Check numeric parameters (array lengths and sizes, simple requirements on validity)
[ok,mess,efix,emode,lattice]=gen_sqw_check_params...
    (n_all_spe_files,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
if ~ok, error('HORACE:gen_sqw:invalid_argument',mess), end


% Check optional arguments (grid, pix_db_range, instrument, sample) for size, type and validity
grid_default=[];
instrument_default=IX_null_inst();  %
sample_default = IX_null_sample();  % default empty sample will be replaced by
%                                   % IX_samp containing lattice at setting
%                                   % it to rundatah
[ok,mess,present,grid_size_in,pix_db_range,instrument,sample]=gen_sqw_check_optional_args(...
    n_all_spe_files,grid_default,instrument_default,sample_default,args{:});
if ~ok, error('HORACE:gen_sqw:invalid_argument',mess), end
if accumulate_old_sqw && (present.grid||present.pix_db_range)
    error('HORACE:gen_sqw:invalid_argument',...
        'If data is being accumulated to an existing sqw file, then you cannot specify the grid or pix_db_range.')
end


% Check the input parameters define unique data sets
if accumulate_old_sqw    % combine with existing sqw file
    if use_partial_tmp
        all_tmp_files=gen_tmp_filenames(spe_file,sqw_file);
        % get pseudo-combined header from list of tmp files
        if log_level>0
            disp(' Analysing headers of existing tmp files:')
        end
        [header_sqw,grid_size_sqw,pix_db_range_sqw,pix_range_present,...
            ind_tmp_files_present,update_runid] = get_tmp_file_headers(all_tmp_files);
        if sum(ind_tmp_files_present) == 0
            accumulate_old_sqw = false;
            if log_level>0
                disp(' No existing tmp files to accumulate found.')
            end
        else
            if log_level>0
                fprintf(' Reusing %d existing tmp files.\n',sum(ind_tmp_files_present))
            end
        end

    else
        % Check that the sqw file has the correct type to which to accumulate
        [ok,mess,header_sqw,grid_size_sqw,pix_db_range_sqw,pix_range_present]=...
            gen_sqw_check_sqwfile_valid(sqw_file);
        % Check that the input spe data are distinct
        if ~ok, error(mess), end
        % It is expected that one would not run replicate and accumulate
        % together and add replicated files without run_id changes after
        % first accumulation because the files with identical run-ids will
        % contribute into pixels but headers (experiment info)
        % will be added for each file
        %
        % Assume:
        % the file has been calculated and run_id-s are stored in the file
        % All its run-id-s are unique, as doing opposite,
        % will be too expensive. Ideally run_id should be stored with
        % headers (experiment_info). The possible issue may occur, if
        % filenames are non-standard, run_id can not extracted from file
        % name and has not been recalculated but additional files will for
        % some reason obtain a run_id, equal to the one, already stored in
        % the file.
        update_runid = false;
    end
    %
    [ok, mess, spe_only, head_only] = gen_sqw_check_distinct_input (spe_file, efix, emode,...
        lattice, instrument, sample, opt.replicate, header_sqw);
    if ~ok, error(mess), end
    if any(head_only) && log_level>-1
        disp('********************************************************************************')
        disp('***  WARNING: The sqw file contains at least one data set that does not      ***')
        disp('***           appear in the list of input spe data sets                      ***')
        disp('********************************************************************************')
        disp(' ')
    end
    if ~any(spe_exist & spe_only)
        if use_partial_tmp
            tmp_file = all_tmp_files(ind_tmp_files_present);
            if log_level>-1
                disp('Creating output sqw file:')
            end
            if update_runid
                wnsq_argi = {};
            else
                wnsq_argi = {'-keep_runid'};
            end
            % will recaluclate pixel_range
            [~,pix_range]=write_nsqw_to_sqw (tmp_file, sqw_file,pix_range_present,wnsq_argi{:});

            if numel(tmp_file) == numel(all_tmp_files)
                tmpf_clob = onCleanup(@()delete_tmp_files(tmp_file,log_level));
                tmp_file={};
            end
        else
            if  log_level>-1  % no work to do
                report_nothing_to_do(spe_only,spe_exist);
            end
            tmp_file={};
            pix_range=pix_range_present;
        end
        grid_size=grid_size_sqw;

        return
    end
    ix=(spe_exist & spe_only);    % the spe data that needs to be processed
else
    [ok, mess] = gen_sqw_check_distinct_input (spe_file, efix, emode,...
        lattice, instrument, sample, opt.replicate);
    if ~ok, error('HORACE:gen_sqw:invalid_argument',mess), end
    % Have already checked that all the spe files exist for the case of generate_new_sqw is true

    if accumulate_new_sqw && ~any(spe_exist)
        error('HORACE:gen_sqw:invalid_argument', ...
            'None of the spe data files exist, so cannot create new sqw file.')
    end
    ix=spe_exist;  % the spe data that needs to be processed
end
indx=find(ix);
nindx=numel(indx);


% Create temporary sqw files, and combine into one (if more than one input file)
% -------------------------------------------------------------------------------
% At this point, there will be at least one spe data input that needs to be turned into an sqw file

% Create fully fledged single crystal rundata objects
if ~isempty(opt.transform_sqw)
    rundata_par = {'transform_sqw',opt.transform_sqw};
else
    rundata_par = {};
end

if accumulate_old_sqw % build only runfiles to process
    run_files = rundatah.gen_runfiles(spe_file(ix),par_file,efix(ix),emode(ix),...
        lattice(ix),instrument(ix),sample(ix),rundata_par{:});
else % build all runfiles, including missing runfiles. TODO: Lost generality
    if isempty(par_file) && sum(spe_exist) ~= n_all_spe_files % missing rf need to use par file from existing runfiles
        % Get detector parameters
        iex1 = indx(1);
        rf1 = rundatah.gen_runfiles(spe_file{iex1},par_file,efix(1),emode(1),...
            lattice(iex1),instrument(iex1),sample(iex1),rundata_par{:});
        par_file = get_par(rf1{1});
    end

    % build all runfiles, including missing runfiles
    run_files = rundatah.gen_runfiles(spe_file,par_file,efix,emode,lattice, ...
        instrument,sample,'-allow_missing',rundata_par{:});
end
% check runfiles correctness
if emode ~= 0
    for i=1:numel(run_files)
        en_tst = run_files{i}.en;
        if ischar(en_tst)
            [~,dfn,dfe] = fileparts(run_files{i}.data_file_name);
            error('HORACE:gen_sqw:invalid_argument',...
                'file: %s, N%d, has incorrect energy bins: %s',[dfn,dfe],i,en_tst);
        end
        efix_tst = run_files{i}.efix;
        if ischar(efix_tst)
            [~,dfn,dfe] = fileparts(run_files{i}.data_file_name);
            error('HORACE:gen_sqw:invalid_argument',...
                'file: %s, N%d, has incorrect efixed: %s',[dfn,dfe],i,efix_tst);
        end

    end
end
% If grid not given, make default size
if ~accumulate_old_sqw && isempty(grid_size_in)
    if n_all_spe_files==1
        grid_size_in=[1,1,1,1];     % for a single spe file, don't sort
    else
        grid_size_in=[50,50,50,50]; % multiple spe files, 50^4 grid
    end
elseif accumulate_old_sqw
    grid_size_in=grid_size_sqw;
end

% If no input data range provided, calculate it from the files
if ~accumulate_old_sqw
    %NOTE: because of && numel(run_files)>1, Masked detectors would be removed
    % from the range of a single converted run file.
    if isempty(pix_db_range) && numel(run_files)>1
        if numel(run_files)==1
            pix_db_range =[];
            pix_range_est = [];
        else
            [pix_db_range,pix_range_est] = find_pix_range(run_files,efix,emode,ix,indx,log_level); %calculate pix_range from all runfiles
        end
    else
        pix_range_est = [];
    end
    run_files = run_files(ix); % select only existing runfiles for further processing
elseif accumulate_old_sqw
    pix_db_range=pix_db_range_sqw;
    pix_range_est = [];
end


% Construct output sqw file
if ~accumulate_old_sqw && nindx==1
    % Create sqw file in one step: no need to create an intermediate file as just one input spe file to convert
    if log_level>-1
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
    end
    if ~isempty(opt.transform_sqw)
        run_files{1}.transform_sqw = opt.transform_sqw;
    end
    if isnan(run_files{1}.run_id)
        run_files{1}.run_id = 1;
    end
    [w,grid_size,pix_range] = run_files{1}.calc_sqw(grid_size_in,pix_db_range);
    verify_pix_range_est(pix_range,pix_range_est,log_level);
    save(w,sqw_file);

    %grid_size_in,pix_db_range_in,write_banner,opt);
    tmp_file={};    % empty cell array to indicate no tmp_files created

    if log_level>-1
        disp('--------------------------------------------------------------------------------')
    end
else
    if opt.replicate && ~spe_unique
        % expand run_ids for replicated files to make run_id-s unique
        run_files = update_duplicated_rf_id(run_files);
    end
    keep_par_cl_running = ~opt.tmp_only || nargout>3;

    % Generate unique temporary sqw files, one for each of the spe files
    [grid_size,pix_range,update_runid,tmp_file,parallel_job_dispatcher]=convert_to_tmp_files(run_files,sqw_file,...
        pix_db_range,grid_size_in,opt.tmp_only,keep_par_cl_running);
    verify_pix_range_est(pix_range,pix_range_est,log_level);

    if keep_par_cl_running
        varargout{1} = parallel_job_dispatcher;
    end

    if use_partial_tmp
        delete_tmp = false;
    end

    if accumulate_old_sqw

        if use_partial_tmp  % if necessary, add already generated and present tmp files
            tmp_file = {all_tmp_files{ind_tmp_files_present},tmp_file{:}}';

            delete_tmp = numel(tmp_file) == n_all_spe_files; % final step in combining tmp files, all tmp files will be generated;

        end
        pix_range = [min(pix_range(1,:),pix_range_present(1,:));...
            max(pix_range(2,:),pix_range_present(2,:))];
    end

    % Accumulate sqw files; if creating only tmp files only, then exit (ignoring the delete_tmp option)
    if ~opt.tmp_only
        if require_spe_unique
            wsqw_arg = {parallel_job_dispatcher};
        else
            wsqw_arg = {'-allow_equal_headers',parallel_job_dispatcher};
        end
        if ~update_runid
            wsqw_arg = {wsqw_arg{:},'-keep_runid'};
        end
        if ~accumulate_old_sqw || use_partial_tmp
            if log_level>-1
                disp('Creating output sqw file:')
            end
            write_nsqw_to_sqw (tmp_file, sqw_file,pix_range,wsqw_arg{:});
        else
            if log_level>-1
                disp('Accumulating in temporary output sqw file:')
            end
            sqw_file_tmp = [sqw_file,'.tmp'];
            write_nsqw_to_sqw ([sqw_file;tmp_file], sqw_file_tmp,pix_range,wsqw_arg{:});
            if log_level>-1
                disp(' ')
                disp(['Renaming sqw file to ',sqw_file])
            end
            rename_file (sqw_file_tmp, sqw_file)
        end

        if log_level>-1
            disp('--------------------------------------------------------------------------------')
        end
    else
        delete_tmp = false;
    end

end
% Delete temporary files at the end, if necessary
if delete_tmp  %if requested
    delete_tmp_files(tmp_file,log_level);
end


% Clear output arguments if nargout==0 to have a silent return
% ------------------------------------------------------------
if nargout==0
    clear tmp_file grid_size pix_range
end

end

function delete_tmp_files(file_list,hor_log_level)
delete_error=false;
for i=1:numel(file_list)
    ws=warning('off','MATLAB:DELETE:Permission');
    try
        delete(file_list{i})
    catch
        if ~delete_error
            delete_error=true;
            if hor_log_level>-1
                disp('One or more temporary sqw files not deleted')
            end
        end
    end
    warning(ws);
end

end

function check_transf_input(input, i)
if ~isa(input,'function_handle')
    error('HORACE:gen_sqw:invalid_argument', ...
          'transform_sqw param N %d \n Error: expecting function handle as value for transform_sqw', i)
end

end

function is = empty_or_missing(fname)
is = isempty(fname) || ~is_file(fname);

end

%------------------------------------------------------------------------------------------------

function [header_sqw,grid_size_sqw,img_db_range_sqw,pix_range,tmp_present,update_runid] = get_tmp_file_headers(tmp_file_names)
% get sqw header for prospective sqw file from range of tmp files
%
% Input:
% tmp_file_names -- list of tmp file names with internal sqw format
%
% Output:
% header_sqw -- list of partial tmp files headers combined in the form,
%               used by sqw file
% grid_size_sqw -- tmp files binning (has to be equal for all input files)
% img_db_range_sqw -- range of input tmp files image (has to be equal for all existing files)
% tmp_present  -- logical array containing true for all tmp_file_names
%                 found on hdd and false otherwise
%
tmp_present = ~cellfun(@empty_or_missing,tmp_file_names,...
    'UniformOutput',true);
files_to_check = tmp_file_names(tmp_present);
header_sqw = cell(numel(files_to_check),1);
multiheaders = false;
ic = 1;
img_db_range_sqw = [];
grid_size_sqw = [];
pix_range = PixelDataBase.EMPTY_RANGE_;

run_ids = zeros(1,numel(files_to_check));
for i=1:numel(files_to_check)
    try
        ldr = sqw_formats_factory.instance().get_loader(files_to_check{i});
        sqw_type = ldr.sqw_type;
        ndims = ldr.num_dim;
        mess = [];
    catch ME
        mess = ME.message;
    end
    if ~isempty(mess) || ~sqw_type || ndims~=4
        tmp_present(i) = false;
        continue;
    end
    if multiheaders
        ic = ic+1;
    end


    % Get header information to check other fields
    % --------------------------------------------
    header = ldr.get_header('-all');
    data   = ldr.get_data('-head');
    pix1  = ldr.get_raw_pix(1,1);
    run_ids(i) = pix1(5);

    pix_range_l = ldr.get_pix_range();
    pix_range = [min(pix_range(1,:),pix_range_l(1,:));...
        max(pix_range(2,:),pix_range_l(2,:))];

    img_db_range_l = data.img_db_range;
    grid_size_l = [numel(data.p{1})-1,numel(data.p{2})-1,...
        numel(data.p{3})-1,numel(data.p{4})-1];

    if isempty(img_db_range_sqw)
        img_db_range_sqw = img_db_range_l;
        grid_size_sqw = grid_size_l;
        data_ref = data;
    else

        tol=2e-7;    % test number to define equality allowing for rounding errors (recall fields were saved only as float32)
        % TGP (15/5/2015) I am not sure if this is necessary: both the header and data sections are saved as float32, so
        % should be rounded identically.
        if ~equal_to_relerr(img_db_range_sqw, img_db_range_l, tol, 1)
            error('GEN_SQW:invalid_argument',...
                'the tmp file to combine: %s does not have the same range as first tmp file',...
                ldr.filename)
        end
        if ~equal_to_relerr(grid_size_sqw, grid_size_l, tol, 1)
            error('GEN_SQW:invalid_argument',...
                'the tmp file to combine: %s does not have the same binning as first tmp file',...
                ldr.filename)
        end

        ok =equal_to_relerr(data_ref.alatt, data.alatt, tol, 1) &...
            equal_to_relerr(data_ref.angdeg, data.angdeg, tol, 1) &...
            equal_to_relerr(data_ref.uoffset, data.uoffset, tol, 1) &...
            equal_to_relerr(data_ref.u_to_rlu(:), data.u_to_rlu(:), tol, 1) &...
            equal_to_relerr(data_ref.ulen, data.ulen, tol, 1);
        if ~ok
            error('HORACE:algorithms:invalid_argument',...
                'the tmp file to combine: %s does not have the the correct projection axes for this operation',...
                ldr.filename)
        end

    end
    if iscell(header) % if tmp files contain more than one header. This is not normal situation
        multiheaders = true;
        if ic<i; ic = i; end
        if ic==numel(header_sqw)
            header_sqw = {header_sqw{1:ic},header{:}};
        else
            header_sqw = {header_sqw{1:ic},header{:},header_sqw{ic+1:end}};
        end
    else
        if multiheaders
            header_sqw{ic} = header;
        else
            header_sqw{i} = header;
        end
    end

end
unique_id = unique(run_ids);
if numel(unique_id)== numel(run_ids)
    update_runid = false;
else
    update_runid = true;
end

end

%-------------------------------------------------------------------------
function  [pix_db_range,pix_range] = find_pix_range(run_files,efix,emode,ief,indx,log_level)
% Calculate ranges of all runfiles provided including missing files
% where only parameters are provided
% inputs:
% runfiles -- list of all runfiles to process. Some may not exist
% efix     -- array of all incident energies
% emode    -- array of data processing modes (direct/indirect elastic)
% ief      -- array of logical indexes where true indicates that runfile
%             exist and false -- not
% indx     -- indices of existing runfiles in array of all runfiles
%Output:
% pix_db_range -- q-dE range of all input data, to rebin pixels on
% pix_range    -- actual q-dE range of the pixel coordinates
%
nindx = numel(indx);
n_all_spe_files = numel(run_files);

if log_level>-1
    disp('--------------------------------------------------------------------------------')
    disp(['Calculating limits of data for ',num2str(n_all_spe_files),' spe files...'])
end

bigtic
pix_range = rundata_find_pix_range(run_files(ief));

% process missing files
if ~all(ief)
    % Get estimate of energy bounds for those spe data that do not actually exist
    eps_lo=NaN(n_all_spe_files,1);
    eps_hi=NaN(n_all_spe_files,1);
    for i=1:nindx
        en=run_files{indx(i)}.en;
        en_cent=0.5*(en(2:end)+en(1:end-1));
        eps_lo(indx(i))=en_cent(1); eps_hi(indx(i))=en_cent(end);
    end
    [eps_lo,eps_hi]=estimate_erange(efix,emode,eps_lo,eps_hi);
    % Compute range with those estimate energy bounds
    missing_rf = run_files(~ief);
    eps_lo = eps_lo(~ief);
    eps_hi = eps_hi(~ief);
    for i = 1:numel(missing_rf)
        missing_rf{i}.en = [eps_lo(i);eps_hi(i)];
    end

    pix_range_est = rundata_find_pix_range(missing_rf);

    % Expand range to include pix_range_est, if necessary
    pix_range=[min(pix_range(1,:),pix_range_est(1,:));...
        max(pix_range(2,:),pix_range_est(2,:))];
end

% Add a border
pix_db_range=range_add_border(pix_range,...
    SQWDnDBase.border_size);

if log_level>-1
    bigtoc('Time to compute limits:',log_level);
end

end

function report_nothing_to_do(spe_only,spe_exist)
disp('--------------------------------------------------------------------------------')
if ~any(spe_only)
    disp('  All the input spe data are already included in the sqw file. No work to do.')
elseif ~any(spe_exist)
    disp('  None of the input spe data currently exist. No work to do.')
else
    disp('  All the input spe data are already included in the sqw file, or do not')
    disp('  currently exist. No work to do.')
end
disp('--------------------------------------------------------------------------------')

end

%---------------------------------------------------------------------------------------

function  [grid_size,pix_range,update_runids,tmp_generated,jd]=convert_to_tmp_files(run_files,sqw_file,...
    pix_db_range,grid_size_in,gen_tmp_files_only,keep_parallel_pool_running)
    % if further operations are necessary to perform with generated tmp files,
    % keep parallel pool running to save time on restarting it.

log_level = config_store.instance().get_value('herbert_config','log_level');
use_separate_matlab = config_store.instance().get_value('hpc_config','build_sqw_in_parallel');
num_matlab_sessions = config_store.instance().get_value('parallel_config','parallel_workers_number');

% build names for tmp files to generate
spe_file = cellfun(@(x)(x.loader.file_name),run_files,...
    'UniformOutput',false);
tmp_file=gen_tmp_filenames(spe_file,sqw_file);
tmp_generated = tmp_file;
if gen_tmp_files_only
    [f_valid_exist,pix_ranges] = cellfun(@(fn)(check_tmp_files_range(fn,pix_db_range,grid_size_in)),...
                                         tmp_file,'UniformOutput',false);
    f_valid_exist = [f_valid_exist{:}];
    if any(f_valid_exist)
        if log_level >0
            warning([' some tmp files exist while generating tmp files only.'...
                ' Generating only new tmp files.'...
                ' Delete all existing tmp files to avoid this'])
        end
        run_files  = run_files(~f_valid_exist);
        tmp_file  = tmp_file(~f_valid_exist);
        pix_ranges = pix_ranges(f_valid_exist);
        pix_range = pix_ranges{1};
        for i=2:numel(pix_ranges)
            pix_range = [min([pix_range(1,:);pix_ranges{i}(1,:)]);...
                max([pix_range(2,:);pix_ranges{i}(2,:)])];
        end
        if isempty(run_files)
            grid_size = grid_size_in;
            update_runids= false;
            jd = [];
            return;
        end
    else
        pix_range = [];
    end
else
    pix_range = [];
end

nt=bigtic();
%write_banner=true;

if use_separate_matlab
    %
    % name parallel job by sqw file name
    [~,fn] = fileparts(sqw_file);
    if numel(fn) > 8
        fn = fn(1:8);
    end
    %
    job_name = ['gen_sqw_',fn];
    %
    jd = JobDispatcher(job_name);

    % aggregate the conversion parameters into array of structures,
    % suitable for splitting jobs between workers
    [common_par,loop_par]=gen_sqw_files_job.pack_job_pars(run_files',tmp_file,...
        grid_size_in,pix_db_range);
    %
    [outputs,n_failed,~,jd] = jd.start_job('gen_sqw_files_job',...
        common_par,loop_par,true,num_matlab_sessions,keep_parallel_pool_running);
    %
    if n_failed == 0
        outputs   = outputs{1};
        grid_size = outputs.grid_size;
        pix_range1 = outputs.pix_range;
        update_runids =outputs.update_runid;
    else
        jd.display_fail_job_results(outputs,n_failed,num_matlab_sessions,'GEN_SQW:runtime_error');
    end
    if ~keep_parallel_pool_running % clear job dispatcher
        jd = [];
    end
else
    jd = [];
    %---------------------------------------------------------------------
    % serial rundata to sqw transformation
    % equivalent of:
    %[grid_size,pix_range] = rundata_write_to_sqw (run_files,tmp_file,...
    %    grid_size_in,pix_range_in,instrument,sample,write_banner,opt);
    %
    % make it look like a parallel transformation. A bit less
    % effective but much easier to identify problem with
    % failing parallel job

    [grid_size,pix_range1,update_runids]=gen_sqw_files_job.runfiles_to_sqw(run_files,tmp_file,...
        grid_size_in,pix_db_range,true);
    %---------------------------------------------------------------------
end

if isempty(pix_range)
    pix_range = pix_range1;
else
    pix_range = [min([pix_range(1,:);pix_range1(1,:)]);...
        max([pix_range(2,:);pix_range1(2,:)])];

end

if log_level>-1
    disp('--------------------------------------------------------------------------------')
    bigtoc(nt,'Time to create all temporary sqw files:',log_level);
    % Create single sqw file combining all intermediate sqw files
    disp('--------------------------------------------------------------------------------')
end

end

function verify_pix_range_est(pix_range,pix_range_est,log_level)

if isempty(pix_range_est)
    pix_range_est = pix_range;
end
if any(abs(pix_range-pix_range_est)>1.e-4, 'all') && log_level>0
    args = arrayfun(@(x)x,[pix_range_est(1,:),pix_range_est(2,:),...
        pix_range(1,:),pix_range(2,:)],'UniformOutput',false);
    warning('gen_sqw:runtime_logic',...
        ['\nEstimated range of contributed pixels differs from the actual calculated range,\n',...
        'Est  min: %+6.4g %+6.4g %+6.4g %+6.4g  | Max:   %+6.4g %+6.4g %+6.4g %+6.4g\n',...
        'Calc min: %+6.4g %+6.4g %+6.4g %+6.4g  | Max:   %+6.4g %+6.4g %+6.4g %+6.4g\n',...
        '%s\n'],...
        args{:},...
        'Estimated range is used for binning pixels so all pixels outside the range are lost');
end

end

function [present_and_valid,img_range] = check_tmp_files_range(tmp_file,pix_db_range,grid_size_in)
% TODO:
% write check for grid_size_in which has to be equal to grid_size of head.
% but head (without s,e,npix) does not have method to idnentify grid_size
% (it should be written and tested)
if ~is_file(tmp_file)
    present_and_valid  = false;
    img_range = [];
    return;
end

tol = 4*eps(single(pix_db_range)); % double of difference between single and double precision

ldr = sqw_formats_factory.instance().get_loader(tmp_file);
img_range = ldr.read_img_range();

present_and_valid = ~any(abs(img_range-pix_db_range)>tol)

end