function [tmp_file,grid_size,urange] = gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
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
%   >> gen_sqw (..., instrument, sample)        % instrument and sample information
%   >> gen_sqw (..., grid_size_in, urange_in)   % grid size and range of data to retain
%   >> gen_sqw (..., grid_size_in, urange_in, instrument, sample)
%
%
% If want output diagnostics:
%   >> [tmp_file,grid_size,urange] = gen_sqw (...)
%
%
% Input: (in the following, nfile = number of spe files)
% ------
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
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
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions
%                   Default if not given or [] is is [50,50,50,50]
%   urange_in       [Optional] Range of data grid for output as a 2x4 matrix:
%                              [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                   Default if not given or [] is the smallest hypercuboid that encloses the whole data range.
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
%
%  'transform_sqw' Keyword, followed by the function or cellarray of functions,
%                  which actually transforms sqw object. The function
%                  should have the form:
%                  wout = f(win) where win is input sqw object and wout --
%                  the transformed one. For example f can symmeterize sqw file:
% i.e:
%   >> gen_sqw(...,...,...,'transform_sqw',@(x)(symmetrise_sqw(x,[0,1,0],[0,0,1],[0,0,0])))
%                  would symmeterize pixels of the generated sqw file by
%                  reflecting them in the plane specified by vectors
%                  [0,1,0], and [0,0,1] (see symmeterise_sqw for details)

%
%
% Output:
% --------
%   tmp_file        Cell array with list of temporary files created by this call to gen_sqw.
%                  If only one input spe file, then no temporary file created, and tmp_file
%                  is an empty cell array.
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid


% T.G.Perring  14 August 2007
% T.G.Perring  19 March 2013   Massively updated, also includes functionality of accumulate_sqw
%
% $Revision$ ($Date$)

% *** Possible improvements
% - Cleverer choice of grid size on the basis of number of data points in the file

d2r=pi/180;     % conversion factor from degrees to radians

% Check that the first argument is sqw object
if ~isa(dummy,classname)    % classname is a private method
    error('Check type of input arguments')
end

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
        error('Invalid option ''clean'' unless also have option ''accumulate''')
    end
    if present.time && (exist(opt.time,'var') || ~isnumeric(opt.time) || opt.time~=0)
        error('Invalid option ''time'' unless also have option ''accumulate'' and/or a date-time vector following')
    end
end
if present.transform_sqw
    for i=1:numel(opt.transform_sqw)
        [ok,mess] = check_fh_input(opt.transform_sqw);
        if ~ok
            error('GEN_SQW:invalid_argument',['transform_sqw param N',...
                num2str(i),' Error: ',mess])
        end
    end
    if numel(opt.transform_sqw)>1
        if numel(opt.transform_sqw) ~= numel(psi)
            error('GEN_SQW:invalid_argument',...
                ['When more then one sqw file transformation is provided', ...
                ' number of transformations should be equal to number of spe ',...
                'files to transform\n.',...
                ' In fact have %d files and %d transformations defined.'],...
                numel(opt.transform_sqw),numel(psi))
        end
    end
end


%If we are to run in 'time' mode, where execution waits for some period,
%then must do so here, because any later we check whether or not spe files
%exist.
if present.time
    if ~isnumeric(opt.time)
        error('Argument following option ''time'' must be vector of date-time format [yyyy,mm,dd,hh,mm,ss]')
    elseif numel(opt.time)~=6
        error('Argument following option ''time'' must be vector of date-time format [yyyy,mm,dd,hh,mm,ss]')
    end
    
    end_time=datenum(opt.time);
    time_now=now;
    
    if end_time<=time_now
        error('Date-time for accumulate_sqw to start is in the past');
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
if opt.replicate,  require_spe_unique=false; else require_spe_unique=true; end
if opt.accumulate, require_spe_exist=false;  else require_spe_exist=true;  end
require_sqw_exist=false;

[ok, mess, spe_file, par_file, sqw_file, spe_exist, spe_unique, sqw_exist] = gen_sqw_check_files...
    (spe_file, par_file, sqw_file, require_spe_exist, require_spe_unique, require_sqw_exist);
if ~ok, error(mess), end
nfiles=numel(spe_file);


% Set the status of flags for the three cases we must handle
% (One and only of the three cases below will be true, the others false.)
accumulate_old_sqw=false;   % true if want to accumulate spe data to an existing sqw file (not all spe data files need exist)
accumulate_new_sqw=false;   % true if want to accumulate spe data to a new sqw file (not all spe data files need exist)
generate_new_sqw=false;          % true if want to generate a new sqw file (all spe data files must exist)
if opt.accumulate
    if sqw_exist && ~opt.clean  % accumulate onto an existing sqw file
        accumulate_old_sqw=true;
    else
        accumulate_new_sqw=true;
    end
else
    generate_new_sqw=true;
end
horace_info_level=get(hor_config,'horace_info_level');

% Check numeric parameters (array lengths and sizes, simple requirements on validity)
[ok,mess,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs]=gen_sqw_check_params...
    (nfiles,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
if ~ok, error(mess), end


% Check optional arguments (grid, urange, instument, sample) for size, type and validity
grid_default=[];
instrument_default=struct;  % default 1x1 struct
sample_default=struct;      % default 1x1 struct
[ok,mess,present,grid_size_in,urange_in,instrument,sample]=gen_sqw_check_optional_args(...
    nfiles,grid_default,instrument_default,sample_default,args{:});
if ~ok, error(mess), end
if accumulate_old_sqw && (present.grid||present.urange)
    error('If data is being accumulated to an existing sqw file, then you cannot specify the grid or urange.')
end


% Check the input parameters define unique data sets
if accumulate_old_sqw    % combine with existing sqw file
    % Check that the sqw file has the correct type to which to accumulate
    [ok,mess,header_sqw,detpar_sqw,grid_size_sqw,urange_sqw]=gen_sqw_check_sqwfile_valid(sqw_file);
    % Check that the input spe data are distinct
    if ~ok, error(mess), end
    [ok, mess, spe_only, head_only] = gen_sqw_check_distinct_input (spe_file, efix, emode, alatt, angdeg,...
        u, v, psi, omega, dpsi, gl, gs, instrument, sample, opt.replicate, header_sqw);
    if ~ok, error(mess), end
    if any(head_only) && horace_info_level>-1
        disp('********************************************************************************')
        disp('***  WARNING: The sqw file contains at least one data set that does not      ***')
        disp('***           appear in the list of input spe data sets                      ***')
        disp('********************************************************************************')
        disp(' ')
    end
    if ~any(spe_exist & spe_only)   % no work to do
        if  horace_info_level>-1
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
        tmp_file={}; grid_size=grid_size_sqw; urange=urange_sqw;
        return
    end
    ix=(spe_exist & spe_only);    % the spe data that needs to be processed
else
    [ok, mess] = gen_sqw_check_distinct_input (spe_file, efix, emode, alatt, angdeg,...
        u, v, psi, omega, dpsi, gl, gs, instrument, sample, opt.replicate);
    if ~ok, error(mess), end
    % Have already checked that all the spe files exist for the case of generate_new_sqw is true
    if accumulate_new_sqw && ~any(spe_exist)
        error('None of the spe data files exist, so cannot create new sqw file.')
    end
    ix=spe_exist;  % the spe data that needs to be processed
end
indx=find(ix);
nindx=numel(indx);


% Create temporary sqw files, and combine into one (if more than one input file)
% -------------------------------------------------------------------------------
% At this point, there will be at least one spe data input that needs to be turned into an sqw file

% Create fully fledged single crystal rundata objects
run_files = gen_runfiles(spe_file(ix),par_file,efix(ix),emode(ix),alatt(ix,:),angdeg(ix,:),...
    u(ix,:),v(ix,:),psi(ix),omega(ix),dpsi(ix),gl(ix),gs(ix));

% If grid not given, make default size
if ~accumulate_old_sqw && isempty(grid_size_in)
    if nfiles==1
        grid_size_in=[1,1,1,1];     % for a single spe file, don't sort
    else
        grid_size_in=[50,50,50,50]; % multiple spe files, 50^4 grid
    end
elseif accumulate_old_sqw
    grid_size_in=grid_size_sqw;
end

% If no input data range provided, calculate it from the files
if ~accumulate_old_sqw && isempty(urange_in)
    if horace_info_level>-1
        disp('--------------------------------------------------------------------------------')
        disp(['Calculating limits of data for ',num2str(nfiles),' spe files...'])
    end
    
    bigtic
    urange_in = rundata_find_urange(run_files);
    if any(~ix)
        % Get detector parameters
        det = get_rundata(run_files{1},'det_par');
        % Get estimate of energy bounds for those spe data that do not actually exist
        eps_lo=NaN(nfiles,1); eps_hi=NaN(nfiles,1);
        for i=1:nindx
            en=run_files{i}.en;
            en_cent=0.5*(en(2:end)+en(1:end-1));
            eps_lo(indx(i))=en_cent(1); eps_hi(indx(i))=en_cent(end);
        end
        [eps_lo,eps_hi]=estimate_erange(efix,emode,eps_lo,eps_hi);
        % Compute range with those estimate energy bounds
        urange_est=calc_urange(efix(~ix),emode(~ix),eps_lo(~ix),eps_hi(~ix),det,alatt(~ix,:),angdeg(~ix,:),...
            u(~ix,:),v(~ix,:),psi(~ix)*d2r,omega(~ix)*d2r,dpsi(~ix)*d2r,gl(~ix)*d2r,gs(~ix)*d2r);
        % Expand range to include urange_est, if necessary
        urange_in=[min(urange_in(1,:),urange_est(1,:)); max(urange_in(2,:),urange_est(2,:))];
    end
    % Add a border
    urange_in=range_add_border(urange_in,-1e-6);
    
    if horace_info_level>-1
        bigtoc('Time to compute limits:',horace_info_level);
    end
    
elseif accumulate_old_sqw
    urange_in=urange_sqw;
end
[use_separate_matlab,num_matlab_sessions]=get(hor_config,'accum_in_separate_process','accumulating_process_num');

% Construct output sqw file
if ~accumulate_old_sqw && nindx==1
    % Create sqw file in one step: no need to create an intermediate file as just one input spe file to convert
    if horace_info_level>-1
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
    end
    write_banner=false;
    [grid_size,urange] = rundata_write_to_sqw (run_files,{sqw_file},...
        grid_size_in,urange_in,instrument(indx(1)),sample(indx(1)),write_banner,opt);
    tmp_file={};    % empty cell array to indicate no tmp_files created
    
    if horace_info_level>-1
        disp('--------------------------------------------------------------------------------')
    end
else
    % Create unique temporary sqw files, one for each of the spe files
    [tmp_file,sqw_file_tmp]=gen_tmp_filenames(spe_file,sqw_file,indx);
    nt=bigtic();
    write_banner=true;
    
    % Older matlab compatibility operator: overcome flaw in indexing empty structure arrays pre 2011b or so.
    if numel(fields(instrument))~=0
        instrument = instrument(indx);
    end
    if numel(fields(sample))~=0
        sample = sample(indx);
    end
    not_empty = cellfun(@(x)(~isempty(x)),spe_file);
    if ~all(not_empty)
        %tmp_file = tmp_file(not_empty);
        instrument = instrument(not_empty);
        sample     = sample(not_empty);
    end
    
    if numel(opt.transform_sqw)>1
        job_par_fun = @(run,fname,instr,samp,transf)(gen_tmp_files_jobs.pack_job_pars(...
            run,fname,instr,samp,...
            grid_size_in,urange_in,struct('transform_sqw',transf)));
        job_par = cellfun(job_par_fun,...
            run_files',tmp_file,num2cell(instrument),num2cell(sample),...
            opt.transf_sqw,...
            'UniformOutput', true);
    else
        job_par_fun = @(run,fname,instr,samp)(gen_tmp_files_jobs.pack_job_pars(...
            run,fname,instr,samp,...
            grid_size_in,urange_in,opt));
        job_par = cellfun(job_par_fun,...
            run_files',tmp_file,num2cell(instrument),num2cell(sample),...
            'UniformOutput', true);
    end
    
    if use_separate_matlab
        %
        % aggregate the conversion parameters into array of structures,
        % suitable for splitting jobs between workers
        %
        % start parallel framework
        [~,par_job_name] = fileparts(sqw_file);
        % name parallel job by sqw file name
        jd = JobDispatcher(upper(par_job_name));
        %
        [n_failed,outputs,job_ids] = jd.send_jobs('gen_tmp_files_jobs',...
            job_par,num_matlab_sessions);
        %
        [grid_size,urange]= check_and_combine_parallel_outputs(n_failed,...
            num_matlab_sessions,outputs,job_ids);
    else
        %---------------------------------------------------------------------
        % serial rundata to sqw transformation
        %[grid_size,urange] = rundata_write_to_sqw (run_files,tmp_file,...
        %    grid_size_in,urange_in,instrument,sample,write_banner,opt);
        % make it looks like parallel transformation though a bit less
        % effective but much easier to debug parallel job
        jex = gen_tmp_files_jobs();
        jex = jex.do_job(job_par);
        result = jex.job_outputs;
        grid_size= result.grid_size;
        urange = result.urange;
        %---------------------------------------------------------------------
    end
    if horace_info_level>-1
        disp('--------------------------------------------------------------------------------')
        bigtoc(nt,'Time to create all temporary sqw files:',horace_info_level);
        % Create single sqw file combining all intermediate sqw files
        disp('--------------------------------------------------------------------------------')
    end
    
    % Accumulate sqw files; if creating only tmp files only, then exit (ignoring the delete_tmp option)
    if ~opt.tmp_only
        if ~accumulate_old_sqw
            if horace_info_level>-1
                disp('Creating output sqw file:')
            end
            write_nsqw_to_sqw (dummy, tmp_file, sqw_file);
        else
            if horace_info_level>-1
                disp('Accumulating in temporary output sqw file:')
            end
            write_nsqw_to_sqw (dummy, [sqw_file;tmp_file], sqw_file_tmp);
            if horace_info_level>-1
                disp(' ')
                disp(['Renaming sqw file to ',sqw_file])
            end
            rename_file (sqw_file_tmp, sqw_file)
        end
        
        if horace_info_level>-1
            disp('--------------------------------------------------------------------------------')
        end
        
        % Delete temporary files
        if get(hor_config,'delete_tmp') %if requested
            delete_error=false;
            for i=1:numel(tmp_file)
                ws=warning('off','MATLAB:DELETE:Permission');
                try
                    delete(tmp_file{i})
                catch
                    if delete_error==false
                        delete_error=true;
                        if horace_info_level>-1
                            disp('One or more temporary sqw files not deleted')
                        end
                    end
                end
                warning(ws);
            end
        end
    end
    
end


% Clear output arguments if nargout==0 to have a silent return
% ------------------------------------------------------------
if nargout==0
    clear tmp_file grid_size urange
end


function  [grid_size,urange]= check_and_combine_parallel_outputs(n_failed,n_workers,outputs,job_ids,job_par)
% verify parallel outputs and reprocess
if n_failed == n_workers
    error('GEN_SQW:separate_process_sqw_generation',...
        [' All parallel jobs have failed.\n',...
        ' Disable parallel sqw generation by setting\n',...
        ' set(hor_config,''accum_in_separate_process'',0)']);
end
if n_failed>0
    warning('GEN_SQW:separate_process_sqw_generation',' %d out of %d jobs to generate tmp files reported failure',...
        n_failed,n_workers);
    for ii=1:numel(outputs)
        if isstruct(outputs)
            continue;
        end
        job_list = job_ids{ii};
        for np = 1:numel(job_list)
            par_num = job_list(np);
            if ~(exist(job_par(par_num).tmp_file,'file')==2)
                warning('GEN_SQW:separate_process_sqw_generation',...
                    ' The target file %s have not been created. Proceeding serially: ',...
                    job_par(par_num).sqw_file_name);
                [grid_size,urange]=runfiles_to_sqw(dummy,job_par(par_num));
            end
            n_failed=n_failed-1;
        end
        outputs{ii} = struct('grid_size',grid_size,...
            'urange',urange);
        
    end
end
%
% check output boundaries produced by all jobs are consistent
grid_size = outputs{1}.grid_size;
urange    = outputs{1}.urange;
for i=2:numel(outputs)
    if ~all(grid_size==outputs{i}.grid_size) || ~all(urange(:)==outputs{i}.urange(:))
        disp('*** Incorrect tmp file ranges ***');
        disp(['Job number: ',num2str(i)]);
        disp(['grid_size: ',num2str(grid_size)])
        disp(['Job grid_size: ',num2str(outputs{i}.grid_size)])
        disp(['urange: ',num2str(urange)])
        disp(['Job urange: ',num2str(outputs{i}.urange)])
        
        error('Logic error in calc_sqw - probably sort_pixels auto-changing grid. Contact T.G.Perring')
    end
end

function  [ok,mess]=check_fh_input(input)
if ~isa(input,'function_handle')
    mess = ' expecting function handle as value for transform_sqw';
    ok = false;
else
    ok = true;
    mess = [];
end


