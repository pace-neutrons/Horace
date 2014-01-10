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
arglist=struct('replicate',0,'accumulate',0,'clean',0);
flags={'replicate','accumulate','clean'};
[args,opt,present] = parse_arguments(varargin,arglist,flags);

if ~opt.accumulate
    if present.clean && opt.clean
        error('Invalid option ''clean'' unless also have option ''accumulate''')
    end
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
elseif accumulate_old_sqw
    urange_in=urange_sqw;
end


% Construct output sqw file
if ~accumulate_old_sqw && nindx==1
    % Create sqw file in one step: no need to create an intermediate file as just one input spe file to convert
	if horace_info_level>-1
		disp('--------------------------------------------------------------------------------')
		disp('Creating output sqw file:')
	end
    [grid_size,urange] = rundata_write_to_sqw (run_files{1},sqw_file,...
        grid_size_in,urange_in,instrument(indx(1)),sample(indx(1)));
    tmp_file={};    % empty cell array to indicate no tmp_files created
    
else
    % Create unique temporary sqw files, one for each of the spe files
    [tmp_file,sqw_file_tmp]=gen_tmp_filenames(spe_file,sqw_file,indx);
    nt=bigtic();
    for i=1:nindx
		if horace_info_level>-1
			disp('--------------------------------------------------------------------------------')
			disp(['Processing spe file ',num2str(i),' of ',num2str(nindx),':'])
			disp(' ')
		end
        [grid_size_tmp,urange_tmp] = rundata_write_to_sqw (run_files{i},tmp_file{i},...
            grid_size_in,urange_in,instrument(indx(i)),sample(indx(i)));
        if i==1
            grid_size = grid_size_tmp;
            urange = urange_tmp;
        else
            if ~all(grid_size==grid_size_tmp) || ~all(urange(:)==urange_tmp(:))
                error('Logic error in code calling rundata_write_to_sqw - probably sort_pixels auto-changing grid. Contact T.G.Perring')
            end
        end
    end
	if horace_info_level>-1
		disp('--------------------------------------------------------------------------------')
		bigtoc(nt,'Time to create all temporary sqw files:');
    
		% Create single sqw file combining all intermediate sqw files
		disp('--------------------------------------------------------------------------------')
	end
	
    if ~accumulate_old_sqw
		if horace_info_level>-1
			disp('Creating output sqw file:')
		end
        write_nsqw_to_sqw (tmp_file, sqw_file);
    else
		if horace_info_level>-1
			disp('Accumulating in temporary output sqw file:')
		end
        write_nsqw_to_sqw ([sqw_file;tmp_file], sqw_file_tmp);
		if horace_info_level>-1		
			disp(' ')
			disp(['Renaming sqw file to ',sqw_file])
		end
        rename_file (sqw_file_tmp, sqw_file)
    end
	if horace_info_level>-1
		disp('--------------------------------------------------------------------------------')
	end
    
    % Delete temporary files if requested
    if get(hor_config,'delete_tmp')
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


% Clear output arguments if nargout==0 to have a silent return
% ------------------------------------------------------------
if nargout==0
    clear tmp_file grid_size urange
end
