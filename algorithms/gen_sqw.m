function [tmp_file,grid_size,urange] = gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
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
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)

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
        error('Invalid option ''clean'' unless also have option ''accumulate''')
    end
    if present.time && (exist(opt.time,'var') || ~isnumeric(opt.time) || opt.time~=0)
        error('Invalid option ''time'' unless also have option ''accumulate'' and/or a date-time vector following')
    end
end
if present.transform_sqw
    for i=1:numel(opt.transform_sqw)
        [ok,mess] = check_transf_input(opt.transform_sqw);
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
if ~ok, error('GEN_SQW:invalid_argument',mess), end
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
[ok,mess,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs]=gen_sqw_check_params...
    (n_all_spe_files,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
if ~ok, error('GEN_SQW:invalid_argument',mess), end


% Check optional arguments (grid, urange, instrument, sample) for size, type and validity
grid_default=[];
instrument_default=struct;  % default 1x1 struct
sample_default=struct;      % default 1x1 struct
[ok,mess,present,grid_size_in,urange_in,instrument,sample]=gen_sqw_check_optional_args(...
    n_all_spe_files,grid_default,instrument_default,sample_default,args{:});
if ~ok, error('GEN_SQW:invalid_argument',mess), end
if accumulate_old_sqw && (present.grid||present.urange)
    error('GEN_SQW:invalid_argument',...
        'If data is being accumulated to an existing sqw file, then you cannot specify the grid or urange.')
end


% Check the input parameters define unique data sets
if accumulate_old_sqw    % combine with existing sqw file
    if use_partial_tmp
        all_tmp_files=gen_tmp_filenames(spe_file,sqw_file);
        % get pseudo-combined header from list of tmp files
        if log_level>0
            disp(' Analysing headers of existing tmp files:')
        end
        [header_sqw,grid_size_sqw,urange_sqw,ind_tmp_files_present] = get_tmp_file_headers(all_tmp_files);
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
        [ok,mess,header_sqw,grid_size_sqw,urange_sqw]=gen_sqw_check_sqwfile_valid(sqw_file);
        % Check that the input spe data are distinct
        if ~ok, error(mess), end
    end
    %
    [ok, mess, spe_only, head_only] = gen_sqw_check_distinct_input (spe_file, efix, emode, alatt, angdeg,...
        u, v, psi, omega, dpsi, gl, gs, instrument, sample, opt.replicate, header_sqw);
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
            
            write_nsqw_to_sqw (tmp_file, sqw_file);
            
            if numel(tmp_file) == numel(all_tmp_files)
                tmpf_clob = onCleanup(@()delete_tmp_files(tmp_file,log_level));
                tmp_file={};
            end
        else
            if  log_level>-1  % no work to do
                report_nothing_to_do(spe_only,spe_exist);
            end
            tmp_file={};
        end
        grid_size=grid_size_sqw; urange=urange_sqw;
        return
    end
    ix=(spe_exist & spe_only);    % the spe data that needs to be processed
else
    if emode == 1
        [ok, mess] = gen_sqw_check_distinct_input (spe_file, efix, emode, alatt, angdeg,...
            u, v, psi, omega, dpsi, gl, gs, instrument, sample, opt.replicate);
        if ~ok, error('GEN_SQW:invalid_argument',mess), end
        % Have already checked that all the spe files exist for the case of generate_new_sqw is true
    end
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
if ~isempty(opt.transform_sqw)
    rundata_par = {'transform_sqw',opt.transform_sqw};
else
    rundata_par = {};
end

if accumulate_old_sqw % build only runfiles to process
    run_files = rundatah.gen_runfiles(spe_file(ix),par_file,efix(ix),emode(ix),...
        alatt(ix,:),angdeg(ix,:),...
        u(ix,:),v(ix,:),psi(ix),omega(ix),dpsi(ix),gl(ix),gs(ix),rundata_par{:});
else % build all runfiles, including missing runfiles. TODO: Lost generality
    if isempty(par_file) && sum(spe_exist) ~= n_all_spe_files % missing rf need to use par file from existing runfiles
        % Get detector parameters
        iex1 = indx(1);
        rf1 = rundatah.gen_runfiles(spe_file{iex1},par_file,efix(1),emode(1),...
            alatt(iex1,:),angdeg(iex1,:),...
            u(iex1,:),v(iex1,:),psi(iex1),omega(iex1),dpsi(iex1),gl(iex1),gs(iex1),rundata_par{:});
        par_file = get_par(rf1{1});
    end
    
    % build all runfiles, including missing runfiles
    run_files = rundatah.gen_runfiles(spe_file,par_file,efix,emode,alatt,angdeg,...
        u,v,psi,omega,dpsi,gl,gs,'-allow_missing',rundata_par{:});
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
    if isempty(urange_in)
        urange_in = find_urange(run_files,efix,emode,ix,indx,log_level); %calculate urange from all runfiles
    end
    run_files = run_files(ix); % select only existing runfiles for further processing
elseif accumulate_old_sqw
    urange_in=urange_sqw;
end


% Construct output sqw file
if ~accumulate_old_sqw && nindx==1
    % Create sqw file in one step: no need to create an intermediate file as just one input spe file to convert
    if log_level>-1
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
    end
    run_files{1}.instrument = instrument(indx(1));
    run_files{1}.sample     = sample(indx(1));
    if ~isempty(opt.transform_sqw)
        run_files{1}.transform_sqw = opt.transform_sqw;
    end
    [w,grid_size,urange] = run_files{1}.calc_sqw(grid_size_in,urange_in); %.rundata_write_to_sqw (run_files,{sqw_file},...
    save(w,sqw_file);
    
    %grid_size_in,urange_in,write_banner,opt);
    tmp_file={};    % empty cell array to indicate no tmp_files created
    
    if log_level>-1
        disp('--------------------------------------------------------------------------------')
    end
else
    % cut instrument and sample to rundata array size
    if verLessThan('matlab','8.0')
        % Older Matlab compatibility operator: overcome flaw in indexing empty structure arrays pre 2011b or so.
        if  numel(fields(instrument))~=0
            instrument = instrument(indx);
        else
            instrument  = repmat(struct(),sum(ix),1);
        end
        if numel(fields(sample))~=0
            sample = sample(indx);
        else
            sample = repmat(struct(),sum(ix),1);
        end
    else
        if ~all(ix)
            %tmp_file = tmp_file(not_empty);
            instrument = instrument(ix);
            sample     = sample(ix);
        end
        
    end
    
    % Generate unique temporary sqw files, one for each of the spe files
    [grid_size,urange,tmp_file,parallel_job_dispatcher]=convert_to_tmp_files(run_files,sqw_file,...
        instrument,sample,urange_in,grid_size_in,opt.tmp_only);
    
    if use_partial_tmp
        delete_tmp = false;
    end
    
    if use_partial_tmp && accumulate_old_sqw  % if necessary, add already generated and present tmp files
        tmp_file = {all_tmp_files{ind_tmp_files_present},tmp_file{:}}';
        if numel(tmp_file) == n_all_spe_files % final step in combining tmp files, all tmp files will be generated
            delete_tmp = true;
        else
            delete_tmp = false;
        end
    end
    
    % Accumulate sqw files; if creating only tmp files only, then exit (ignoring the delete_tmp option)
    if ~opt.tmp_only
        if require_spe_unique
            wsqw_arg = {parallel_job_dispatcher};
        else
            wsqw_arg = {'allow_equal_headers',parallel_job_dispatcher};
        end
        if ~accumulate_old_sqw || use_partial_tmp
            if log_level>-1
                disp('Creating output sqw file:')
            end
            write_nsqw_to_sqw (tmp_file, sqw_file,wsqw_arg{:});
        else
            if log_level>-1
                disp('Accumulating in temporary output sqw file:')
            end
            sqw_file_tmp = [sqw_file,'.tmp'];
            write_nsqw_to_sqw ([sqw_file;tmp_file], sqw_file_tmp,wsqw_arg{:});
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
    clear tmp_file grid_size urange
end
% clear cached detectors information and detectors directions
rundatah.clear_det_cache();

function delete_tmp_files(file_list,hor_log_level)
delete_error=false;
for i=1:numel(file_list)
    ws=warning('off','MATLAB:DELETE:Permission');
    try
        delete(file_list{i})
    catch
        if delete_error==false
            delete_error=true;
            if hor_log_level>-1
                disp('One or more temporary sqw files not deleted')
            end
        end
    end
    warning(ws);
end



function  [ok,mess]=check_transf_input(input)
if ~isa(input,'function_handle')
    mess = ' expecting function handle as value for transform_sqw';
    ok = false;
else
    ok = true;
    mess = [];
end


function is = empty_or_missing(fname)
if isempty(fname)
    is  = true;
else
    if exist(fname,'file') == 2
        is = false;
    else
        is  = true;
    end
end

%------------------------------------------------------------------------------------------------
function [header_sqw,grid_size_sqw,urange_sqw,tmp_present] = get_tmp_file_headers(tmp_file_names)
% get sqw header for prospective sqw file from range of tmp files
%
% Input:
% tmp_file_names -- list of tmp file names with internal sqw format
%
% Output:
% header_sqw -- list of partial tmp files headers combined in the form,
%               used by sqw file
% grid_size_sqw -- tmp files binning (has to be equal for all input files)
% urange_sqw   -- q-range of input tmp files (has to be equal for all existing files)
% tmp_present  -- logical array containing true for all tmp_file_names
%                 found on hdd and false otherwise
%
tmp_present = ~cellfun(@empty_or_missing,tmp_file_names,...
    'UniformOutput',true);
files_to_check = tmp_file_names(tmp_present);
header_sqw = cell(numel(files_to_check),1);
multiheaders = false;
ic = 1;
urange_sqw = [];
grid_size_sqw = [];
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
    
    if isempty(urange_sqw)
        urange_sqw=[data.p{1}(1) data.p{2}(1) data.p{3}(1) data.p{4}(1); ...
            data.p{1}(end) data.p{2}(end) data.p{3}(end) data.p{4}(end)];
        grid_size_sqw = [numel(data.p{1})-1,numel(data.p{2})-1,...
            numel(data.p{3})-1,numel(data.p{4})-1];
        data_ref = data;
    else
        urange_l=[data.p{1}(1) data.p{2}(1) data.p{3}(1) data.p{4}(1); ...
            data.p{1}(end) data.p{2}(end) data.p{3}(end) data.p{4}(end)];
        grid_size_l = [numel(data.p{1})-1,numel(data.p{2})-1,...
            numel(data.p{3})-1,numel(data.p{4})-1];
        
        tol=2e-7;    % test number to define equality allowing for rounding errors (recall fields were saved only as float32)
        % TGP (15/5/2015) I am not sure if this is necessary: both the header and data sections are saved as float32, so
        % should be rounded identically.
        if ~equal_to_relerr(urange_sqw, urange_l, tol, 1)
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
            error('GEN_SQW:invalid_argument',...
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
%-------------------------------------------------------------------------
function  urange_in = find_urange(run_files,efix,emode,ief,indx,log_level)
% Calculate ranges of all runfiles provided including missing files
% where only parameters are provided
% inputs:
% runfiles -- list of all runfiles to process. Some may not exist
% efix     -- array of all incident energies
% emode    -- array of data processing modes (direct/indirect elastic)
% ief      -- array of logical indexes where true indicates than runfile
%             exist and false -- not
% indx     -- indexes of existing runfiles in array of all runfiles
%Output:
% urange_in -- q-dE range of all input data
%
use_mex = ...
    config_store.instance().get_value('hor_config','use_mex');
nindx = numel(indx);
n_all_spe_files = numel(run_files);

if log_level>-1
    disp('--------------------------------------------------------------------------------')
    disp(['Calculating limits of data for ',num2str(n_all_spe_files),' spe files...'])
end

if use_mex
    cache_det = {};
else
    cache_det  = {'-cache_detectors'};
end

bigtic
urange_in = rundata_find_urange(run_files(ief),cache_det{:});

% process missing files
if ~all(ief)
    % Get estimate of energy bounds for those spe data that do not actually exist
    eps_lo=NaN(n_all_spe_files,1); eps_hi=NaN(n_all_spe_files,1);
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
    
    urange_est = rundata_find_urange(missing_rf,cache_det{:});
    
    % Expand range to include urange_est, if necessary
    urange_in=[min(urange_in(1,:),urange_est(1,:)); max(urange_in(2,:),urange_est(2,:))];
end
% Add a border
urange_in=range_add_border(urange_in,-1e-6);

if log_level>-1
    bigtoc('Time to compute limits:',log_level);
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
%---------------------------------------------------------------------------------------
function  [grid_size,urange,tmp_file,jd]=convert_to_tmp_files(run_files,sqw_file,...
    instrument,sample,urange_in,grid_size_in,gen_tmp_files_only)
%
log_level = ...
    config_store.instance().get_value('herbert_config','log_level');
[use_separate_matlab,num_matlab_sessions] = ...
    config_store.instance().get_value('hpc_config',...
    'build_sqw_in_parallel','parallel_workers_number');

% build names for tmp files to generate
spe_file = cellfun(@(x)(x.loader.file_name),run_files,...
    'UniformOutput',false);
tmp_file=gen_tmp_filenames(spe_file,sqw_file);
if gen_tmp_files_only
    f_exist = cellfun(@(fn)(exist(fn,'file')==2),tmp_file,'UniformOutput',true);
    if any(f_exist)
        if log_level >0
            warning([' some tmp files exist while generating tmp files only.'...
                ' Generating only new tmp files.'...
                ' Delete all existing tmp files to avoid this'])
        end
        run_files  = run_files(~f_exist);
        tmp_file  = tmp_file(~f_exist);
    end
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
    if gen_tmp_files_only
        keep_parallel_pool_running = false;
    else % if further operations are necessary to perform with generated tmp files,
        % keep parallel pool running to save time on restarting it
        keep_parallel_pool_running = true;
    end
    
    % aggregate the conversion parameters into array of structures,
    % suitable for splitting jobs between workers
    [common_par,loop_par]=gen_sqw_files_job.pack_job_pars(run_files',tmp_file,...
        instrument,sample,grid_size_in,urange_in);
    %
    [outputs,n_failed,~,jd] = jd.start_job('gen_sqw_files_job',...
        common_par,loop_par,true,num_matlab_sessions,keep_parallel_pool_running);
    %
    if n_failed == 0
        grid_size = outputs.grid_size;
        urange    = outputs.urange;
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
    %[grid_size,urange] = rundata_write_to_sqw (run_files,tmp_file,...
    %    grid_size_in,urange_in,instrument,sample,write_banner,opt);
    %
    % make it look like a parallel transformation. A bit less
    % effective but much easier to identify problem with
    % failing parallel job
    
    [grid_size,urange]=gen_sqw_files_job.runfiles_to_sqw(run_files,tmp_file,...
        grid_size_in,urange_in,true);
    %---------------------------------------------------------------------
end
if log_level>-1
    disp('--------------------------------------------------------------------------------')
    bigtoc(nt,'Time to create all temporary sqw files:',log_level);
    % Create single sqw file combining all intermediate sqw files
    disp('--------------------------------------------------------------------------------')
end
