function [tmp_file,grid_size,data_range,varargout] = gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
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
%   data_range     The actual range of pixels contributing into sqw file
%                  constisting of 4 first elements of pixel coordinates
%                   (min/max coordinates in crystal cartesian)
%                   and 5 elements of min/max values of pixel signal/error/etc.
%   wout            If requested, instance of filebacked generated sqw
%                   file. If 'tmp_only' option is provided so no tmp file
%                   is generated, it will be 2x4 array of image_ranges,
%                   where the pixels are rebin on.
%


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
else
    opt.clean = true;
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
require_spe_unique  = ~opt.replicate;
require_spe_exist   = ~opt.accumulate;
require_sqw_exist=false;

%CM:use of par file
[spe_file, par_file, sqw_file, spe_exist, spe_unique, sqw_exist] = gen_sqw_check_files...
    (spe_file, par_file, sqw_file, require_spe_exist, require_spe_unique, require_sqw_exist);

n_all_spe_files=numel(spe_file);


% Set the status of flags for the three cases we must handle
% (One and only of the three cases below will be true, the others false.)
accumulate_old_sqw= false;   % true if want to accumulate spe data to an existing sqw file (not all spe data files need to exist)
accumulate_new_sqw= false;   % true if want to accumulate spe data to a new sqw file (not all spe data files need exist)
return_result     = nargout > 3; % uf nargout> 3 return result whatever it may be.
% previous accumulation steps
[delete_tmp, log_level] = get(hor_config,'delete_tmp', 'log_level');
combine_algorithm = get(hpc_config,'combine_sqw_using');

if opt.accumulate
    if sqw_exist && ~opt.clean  % accumulate onto an existing sqw file
        accumulate_old_sqw=true;
    else
        accumulate_new_sqw=true;
    end
    if ~strcmpi(combine_algorithm,'mpi_code') % use tmp rather than sqw file as source of
        opt.clean = true;                   % input data (works faster as parallel jobs are better balanced)
    end
end


% Check numeric parameters (array lengths and sizes, simple requirements on validity)
[ok,mess,efix,emode,lattice]=gen_sqw_check_params...
    (n_all_spe_files,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
if ~ok, error('HORACE:gen_sqw:invalid_argument',mess), end


% Check optional arguments (grid, pix_db_range, instrument, sample) for size, type and validity
grid_default=[];
instrument_default=IX_null_inst();  %
sample_default = IX_samp();  % default empty sample will be replaced by
%                                   % IX_samp containing lattice at setting
%                                   % it to rundatah
[present,grid_size_in,pix_db_range,instrument,sample]=gen_sqw_check_optional_args(...
    n_all_spe_files,grid_default,instrument_default,sample_default,lattice,args{:});
if accumulate_old_sqw && (present.grid||present.pix_db_range)
    error('HORACE:gen_sqw:invalid_argument',...
        'If data is being accumulated to an existing sqw file, then you cannot specify the grid or pix_db_range.')
end


% Check the input parameters define unique data sets
if accumulate_old_sqw    % combine with existing sqw file
    error('HORACE:gen_sqw:not_implemented', ...
        'Old sqw file accumulation is not yet implemented')
else
    gen_sqw_check_distinct_input (spe_file, efix, emode,...
        lattice, instrument, sample, opt.replicate);

    % Have already checked that all the spe files exist for the case of generate_new_sqw is true
    if accumulate_new_sqw && ~any(spe_exist)
        error('HORACE:gen_sqw:invalid_argument', ...
            'None of the spe data files exist, so cannot create new sqw file.')
    end
    ix=spe_exist;  % the spe data that needs to be processed
end
all_spe_present = all(ix); % are there missing spe files?
indx=find(ix);
nindx=numel(indx);


% Create temporary sqw files, and combine into one (if more than one input file)
% -------------------------------------------------------------------------------
% At this point, there will be at least one spe data input that needs to be turned into an sqw file
if opt.replicate
    rundata_par = {'-replicate'};
else
    rundata_par = {};
end
if ~isempty(opt.transform_sqw)
    rundata_par = {rundata_par{:},'transform_sqw',opt.transform_sqw};
end


% Create fully fledged single crystal rundata objects
% build all runfiles, including missing runfiles. TODO: Lost generality, assume detectors are all equvalent
empty_par_files = cellfun(@isempty,par_file);
if any(empty_par_files) && sum(spe_exist) ~= n_all_spe_files % missing rf may need to use different
    % par file (what is currently there) from what will be there later
    % NB might be easier to do any(spe_exist==0)
    empty_par_files = find(empty_par_files);

    % Get detector parameters from a known spe
    iex1 = indx(1);
    rf1 = rundatah.gen_runfiles(spe_file{iex1},par_file(iex1),efix(1),emode(1),...
        lattice(iex1),instrument(iex1),sample(iex1),rundata_par{:});
    rf1_pfile = get_par(rf1{1}); %CM:get_par(
    par_file(empty_par_files) = {rf1_pfile};
end

% build all runfiles, including missing runfiles
rundata_par = ['-allow_missing';rundata_par(:)];
[run_files,~,new_duplicates] = rundatah.gen_runfiles(spe_file,par_file,efix,emode,lattice, ...
    instrument,sample,rundata_par{:});
if ~isempty(new_duplicates)
    clDuplicates = onCleanup(@()del_memmapfile_files(new_duplicates));
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
if isempty(grid_size_in)
    if n_all_spe_files==1
        grid_size_in=[1,1,1,1];     % for a single spe file, don't sort
    else
        grid_size_in=[50,50,50,50]; % multiple spe files, 50^4 grid
    end
end

% If no input data range provided, calculate it from the files

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
    pix_range_est = pix_db_range;
end
run_files = run_files(ix); % select only existing runfiles for further processing
% Construct output sqw file
if nindx==1
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
    [w,grid_size,data_range] = run_files{1}.calc_sqw(grid_size_in,pix_db_range);
    verify_pix_range_est(data_range(:,1:4),pix_range_est,log_level);
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
    [tmp_file,data_range,update_runid,grid_size,parallel_job_dispatcher]=...
        convert_to_tmp_files(run_files,sqw_file,...
        pix_db_range,grid_size_in,opt.accumulate,keep_par_cl_running);
    if numel(ix) == numel(indx) % if all files are present, check if
        % estimated pixel range is equal to the actual range of all
        % contributing runfiles. Give warning about possibility to lose
        % pixels if actual range differs from the expected range
        verify_pix_range_est(data_range(:,1:4),pix_range_est,log_level);
    end

    % Accumulate sqw files; if creating only tmp files only, then exit (ignoring the delete_tmp option)
    if ~opt.tmp_only
        if isempty(parallel_job_dispatcher)
            wsqw_arg  = {};
        else
            wsqw_arg = {parallel_job_dispatcher};
        end

        if ~require_spe_unique
            wsqw_arg = ['-allow_equal_headers';wsqw_arg(:)];
        end
        if ~update_runid
            wsqw_arg = [wsqw_arg(:);'-keep_runid'];
        end

        if log_level>-1
            disp('Creating output sqw file:')
        end
        if return_result
            [~,data_range,wout]=write_nsqw_to_sqw (tmp_file, sqw_file,data_range,wsqw_arg{:});
            varargout{1} = wout;
        else
            write_nsqw_to_sqw (tmp_file, sqw_file,data_range,wsqw_arg{:});
        end
        if log_level>-1
            disp('--------------------------------------------------------------------------------')
        end
        % if not all spe are provided, do not delete tmp to be able to
        % continue later
        delete_tmp = delete_tmp && all_spe_present;
    else
        delete_tmp = false;
    end

end
% Delete temporary files at the end, if necessary
if delete_tmp %if requested
    delete_tmp_files(tmp_file,log_level);
end
if return_result && opt.tmp_only
    varargout{1} = pix_db_range;
end


% Clear output arguments if nargout==0 to have a silent return
% ------------------------------------------------------------
if nargout==0
    clear tmp_file grid_size
end
end
%==========================================================================
% USED ROUTINES:
%==========================================================================
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
    pix_range=minmax_ranges(pix_range,pix_range_est);
end

% Add a border
pix_db_range=range_add_border(pix_range,...
    SQWDnDBase.border_size);

if log_level>-1
    bigtoc('Time to compute limits:',log_level);
end
end
%---------------------------------------------------------------------------------------

function verify_pix_range_est(pix_range,pix_range_est,log_level)
% check if any pixels in from the actual pixel ranges range are outside
% of the range, evaluated or provided earlier.
if isempty(pix_range_est)
    pix_range_est = pix_range;
end

if ~is_range_wider(pix_range_est(:,1:4),pix_range(:,1:4)) && log_level>0
    args = arrayfun(@(x)x,[ ...
        pix_range_est(1,1:4),pix_range_est(2,1:4),pix_range(1,1:4),pix_range(2,1:4), ...
        pix_range_est(1,1:4)-pix_range(1,1:4),pix_range(2,1:4)-pix_range_est(2,1:4)], ...
        'UniformOutput',false);
    warning('gen_sqw:runtime_logic',['\n',...
        '*** **************************************************************************************************\n',...
        '*** Actual pixels range is wider than range used for binning pixels: *********************************\n',...
        '*** Binning   min: %+8.4f %+8.4f %+8.4f %+8.4f  |   Max:   %+8.4f %+8.4f %+8.4f %+8.4f\n',...
        '*** Actual    min: %+8.4f %+8.4f %+8.4f %+8.4f  |   Max:   %+8.4f %+8.4f %+8.4f %+8.4f\n',...
        '*** Cut from Left: %+8.1e %+8.1e %+8.1e %+8.1e  | Right:   %+8.1e %+8.1e %+8.1e %+8.1e\n',...
        '*** All pixels outside the binning range have been lost              *********************************\n',...
        '*** **************************************************************************************************\n'],...
        args{:});
end
end
