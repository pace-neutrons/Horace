function [tmp_file,grid_size,urange] = gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                u, v, psi, omega, dpsi, gl, gs, varargin)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
% Normal use:
%   >> gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs)
%  optionally, in addition:
%   >> gen_sqw (..., grid_size_in, urange_in)   % grid size and range of data to retain
%   >> gen_sqw (..., instrument, sample)        % instrument and sample information
%   >> gen_sqw (..., grid_size_in, urange_in, instrument, sample)
%
%
% If want output diagnostics:
%   >> [tmp_file,grid_size,urange] = gen_sqw (spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% Input: (in the following, nfile = no. spe files)
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
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions
%                   Default if not given or [] is is [50,50,50,50]
%   urange_in       [Optional] Range of data grid for output as a 2x4 matrix:
%                              [x1_lo,x2_lo,x3_lo,x4_lo;x1_hi,x2_hi,x3_hi,x4_hi]
%                   Default if not given or [] is the smallest hypercuboid that encloses the whole data range.
%   instrument      Structure or object containing instrument information [scalar or array length nfile]
%   sample          Structure or object containing sample geometry information [scalar or array length nfile]
%
%
% Output:
% --------
%   tmp_file        Cell array with list of temporary files. If only one input spe file, then
%                  no temporary file created, and tmp_file is an cell array size 1x1 with no contents
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid

% T.G.Perring  14 August 2007


% *** Possible improvements
% - Cleverer choice of grid size on the basis of number of data points in the file


% Check input arguments
% ---------------------
% Check that the first argument is sqw object
if ~isa(dummy,classname)    % classname is a private method
    error('Check type of input arguments')
end

% Check file names
check_spe_exist=true;
check_spe_unique=true;
check_sqw_exist=false;
[spe_file, par_file, sqw_file, spe_exist, spe_unique, sqw_exist] = gen_sqw_check_files...
    (spe_file, par_file, sqw_file, check_spe_exist, check_spe_unique, check_sqw_exist);
nfiles=numel(spe_file);

% Check numeric parameters
[efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs]=gen_sqw_check_params...
    (nfiles,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);

% Check optional arguments
if nfiles==1
    grid_default=[1,1,1,1];     % for a single spe file, don't sort
else 
    grid_default=[50,50,50,50]; % multiple spe files, 50^4 grid
end
instrument_default=struct;  % default 1x1 struct
sample_default=struct;      % default 1x1 struct
[grid_size_in,urange_in,instrument,sample]=gen_sqw_check_optional_args(nfiles,grid_default,instrument_default,sample_default,varargin{:});

% Information for tmp files
tmp_file = cell(1,nfiles);
tmp_sqw_path = fileparts(sqw_file);
tmp_sqw_ext = '.tmp';


% Create temporary sqw files, and combine into one (if more than one input file)
% -------------------------------------------------------------------------------
% Branch depending if use Herbert rundata class, or original libisis processing

if is_herbert_used()    % =============================> rundata class processing
    % Create fully fledged single crystal rundata objects
    run_files = gen_runfiles(spe_file,par_file,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);

    % If no input data range provided, calculate it from the files
    if isempty(urange_in)
        urange_in = rundata_find_urange(run_files);
    end
    
    % Construct output sqw file
    if nfiles==1
        % Create sqw file in one step: no need to create an intermediate file as just one input spe file
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
        [grid_size,urange] = rundata_write_to_sqw (run_files{1},sqw_file,grid_size_in,urange_in,instrument(1),sample(1));
        
    else
        % Create temporary sqw files, one for each of the spe files
        nt=bigtic();
        for i=1:nfiles
            disp('--------------------------------------------------------------------------------')
            disp(['Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
            disp(' ')
            [source_path,source_name]=get_source_fname(run_files{i});
            tmp_file{i}=fullfile(tmp_sqw_path,[source_name,tmp_sqw_ext]);
            [grid_size_tmp,urange_tmp] = rundata_write_to_sqw (run_files{i},tmp_file{i},grid_size_in,urange_in,instrument(i),sample(i));
            if i==1
                grid_size = grid_size_tmp;
                urange = urange_tmp;
            else
                if ~all(grid_size==grid_size_tmp) || ~all(urange(:)==urange_tmp(:))
                    error('Logic error in code calling rundata_write_to_sqw')
                end
            end
        end
        disp('--------------------------------------------------------------------------------')
        bigtoc(nt,'Time to create all temporary sqw files:');
        
        % Create single sqw file combining all intermediate sqw files
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
        write_nsqw_to_sqw (tmp_file, sqw_file);
        disp('--------------------------------------------------------------------------------')
    end
    
else   % =============================> Libisis spe/par file processing
    % Convert input angles to radians (except lattice parameters)
    deg2rad=pi/180;
    psi = psi*deg2rad;
    omega = omega*deg2rad;
    dpsi = dpsi*deg2rad;
    gl = gl*deg2rad;
    gs = gs*deg2rad;
    
    % Pre-form speData objects
    spe_data=cell(1,nfiles);
    for i=1:nfiles
        spe_data{i}=speData(spe_file{i});
    end
    
    % If no input data range provided, calculate it from the files
    if isempty(urange_in)
        urange_in = speData_find_urange(spe_data, par_file,...
            efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
    end

    % Construct output sqw file
    if nfiles==1
        % Create sqw file in one step: no need to create an intermediate file as just one input spe file
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
        [grid_size,urange] = speData_write_to_sqw (spe_data{1},par_file,sqw_file,...
            efix(1),emode(1),alatt(1,:),angdeg(1,:),u(1,:),v(1,:),psi(1),omega(1),dpsi(1),gl(1),gs(1),...
            grid_size_in,urange_in,instrument(1),sample(1));

    else
        % Create temporary sqw files, one for each of the spe files
        nt=bigtic();
        for i=1:nfiles
            disp('--------------------------------------------------------------------------------')
            disp(['Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
            disp(' ')
            [source_path,source_name]=fileparts(spe_file{i});   % *** should be a method similar to that for rundata to get file name
            tmp_file{i}=fullfile(tmp_sqw_path,[source_name,tmp_sqw_ext]);
            [grid_size_tmp,urange_tmp] = speData_write_to_sqw (spe_data{i},par_file,tmp_file{i},...
                efix(i),emode(i),alatt(i,:),angdeg(i,:),u(i,:),v(i,:),psi(i),omega(i),dpsi(i),gl(i),gs(i),...
                grid_size_in,urange_in,instrument(i),sample(i));
            if i==1
                grid_size = grid_size_tmp;
                urange = urange_tmp;
            else
                if ~all(grid_size==grid_size_tmp) || ~all(urange(:)==urange_tmp(:))
                    error('Logic error in code calling rundata_write_to_sqw')
                end
            end
        end
        disp('--------------------------------------------------------------------------------')
        bigtoc(nt,'Time to create all temporary sqw files:');

        % Create single sqw file combining all intermediate sqw files
        % ------------------------------------------------------------
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
        write_nsqw_to_sqw (tmp_file, sqw_file);
        disp('--------------------------------------------------------------------------------')
    end
end


% Delete temporary files if requested
% -----------------------------------
if get(hor_config,'delete_tmp')
    if ~isempty(tmp_file)   % will be empty if only one spe file
        delete_error=false;
        for i=1:numel(tmp_file)
            try
                delete(tmp_file{i})
            catch
                if delete_error==false
                    delete_error=true;
                    disp('One or more temporary sqw files not deleted')
                end
            end
        end
    end
end


% Clear output arguments if nargout==0 to have a silent return
% ------------------------------------------------------------
if nargout==0
    clear tmp_file grid_size urange
end
