function [tmp_file,grid_size,urange] = gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
                                                u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
% Normal use:
%   >> gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
% If want output diagnostics:
%   >> [tmp_file,grid_size,urange] = gen_sqw (dummy, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                                               u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
% Input: (in the following, nfile = no. spe files)
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   spe_file        Full file name of spe file - character string or cell array of
%                  character strings for more than one file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions. Default is [50,50,50,50]
%   urange_in       [Optional] Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range.
%
% Output:
% --------
%   tmp_file        List of temporary files
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid

% T.G.Perring  14 August 2007


% Check that the first argument is sqw object
% -------------------------------------------
if ~isa(dummy,classname)    % classname is a private method 
    error('Check type of input arguments')
end

% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------
if ~(nargin>=15 && nargin<=17)
    error('Check number of input arguments')
end

% Check input arguments
% ------------------------
% Input files
if ischar(spe_file) && size(spe_file,1)==1
    spe_file=cellstr(spe_file);
elseif ~iscellstr(spe_file)
    error('spe file input must be a single file name or cell array of file names')
end
nfiles = length(spe_file);
% Check that the spe files are all unique
if ~(size(unique(spe_file),2)==size(spe_file,2))
    error('One or more spe file name is repeated. All spe files must be unique')
end
% Check that all the files exist
% not necessary as this check fails if hdf files used as source. Moreover, this check is automatically performed in speData class constructor
%for i=1:nfiles
%    if exist(spe_file{i},'file')~=2
%        error(['File ',spe_file{i},' not found'])
%    end
%end


% Check par file and output sqw file are character rows (easy mistake to think that cellstr are allowed input to gen_sqw)
if ~(ischar(par_file) && size(par_file,1)==1) || ~(ischar(sqw_file) && size(sqw_file,1)==1)
    error ('Just one each of detector parameter file and output sqw file permitted')
end
% Check that output file does not appear in input file name list
if ~isempty(strmatch(par_file,spe_file,'exact'))
    error('Detector parameter file name matches one of the input spe file names')
elseif ~isempty(strmatch(sqw_file,spe_file,'exact'))
    error('Output sqw file name matches one of the input spe file names')
elseif strcmpi(par_file,sqw_file)
    error('Detector parameter file and output sqw file name match')
end
% Check par file exists
if exist(par_file,'file')~=2
    error(['File ',par_file,' not found'])
end


% Expand the input variables to vectors where values can be different for each spe file
if isscalar(efix) && nfiles>1 && isnumeric(efix)
    efix=repmat(efix,[nfiles,1]);
elseif ~(isvector(efix) && length(efix)==nfiles && isnumeric(efix))
    error ('Efix must be a single number vector with length equal to the number of spe files')
end

if isscalar(psi) && nfiles>1 && isnumeric(psi)
    psi=repmat(psi,[nfiles,1]);
elseif ~(isvector(psi) && length(psi)==nfiles && isnumeric(psi))
    error ('psi must be a single number vector with length equal to the number of spe files')
end

if isscalar(omega) && nfiles>1 && isnumeric(omega)
    omega=repmat(omega,[nfiles,1]);
elseif ~(isvector(omega) && length(omega)==nfiles && isnumeric(omega))
    error ('omega must be a single number vector with length equal to the number of spe files')
end

if isscalar(dpsi) && nfiles>1 && isnumeric(dpsi)
    dpsi=repmat(dpsi,[nfiles,1]);
elseif ~(isvector(dpsi) && length(dpsi)==nfiles && isnumeric(dpsi))
    error ('dpsi must be a single number vector with length equal to the number of spe files')
end

if isscalar(gl) && nfiles>1 && isnumeric(gl)
    gl=repmat(gl,[nfiles,1]);
elseif ~(isvector(gl) && length(gl)==nfiles && isnumeric(gl))
    error ('gl must be a single number vector with length equal to the number of spe files')
end

if isscalar(gs) && nfiles>1 && isnumeric(gs)
    gs=repmat(gs,[nfiles,1]);
elseif ~(isvector(gs) && length(gs)==nfiles && isnumeric(gs))
    error ('gs must be a single number vector with length equal to the number of spe files')
end

% Convert input angles to radians (except lattice parameters)
deg2rad=pi/180;
psi = psi*deg2rad;
omega = omega*deg2rad;
dpsi = dpsi*deg2rad;
gl = gl*deg2rad;
gs = gs*deg2rad;

% Set default grid size if none given
if ~exist('grid_size_in','var')
    disp('--------------------------------------------------------------------------------')
    disp('Using default grid size of 50x50x50x50 for output sqw file')
    grid_size_in=[50,50,50,50];
elseif ~(isnumeric(grid_size_in)&&(isscalar(grid_size_in)||(isvector(grid_size_in)&&all(size(grid_size_in)==[1,4]))))
    error ('Grid size must be scalar or row vector length 4')
end

% Check urange_in is valid, if provided
if exist('urange_in','var')
    if ~(isnumeric(urange_in) && length(size(urange_in))==2 && all(size(urange_in)==[2,4]) && all(urange_in(2,:)-urange_in(1,:)>=0))
        error('urange must be 2x4 array, first row lower limits, second row upper limits, with lower<=upper')
    end
end

% Make names of intermediate files
tmp_file = cell(size(spe_file));
spe_data = cell(size(spe_file));

sqw_path=fileparts(sqw_file);
for i=1:nfiles
 % build spe data structure on the basis of spe or hdf files 
    spe_data{i}=speData(spe_file{i});% The files can be found by its name. 
                                     % If the files can not be found,the
                                     % constructor fails (throw an error)
    if ~isempty(getEi(spe_data{i}))
        efix(i) = getEi(spe_data{i});
    end
    [spe_path,spe_name,spe_ext]=fileparts(spe_file{i});
    if strcmpi(spe_ext,'.tmp')
        error('Extension type ''.tmp'' not permitted for spe input files. Rename file(s)')
    end
    tmp_file{i}=fullfile(sqw_path,[spe_name,'.tmp']);
end


% Get limits of data for grid on which to store sqw data
% ---------------------------------------------------------
% Use the fact that the lowest and highest energy transfer bin centres define the maximum extent in
% momentum and energy. We calculate using the full detector table i.e. do not account for masked detectors
% but this is reasonable so long as not many detecotrs are masked. 
% (*** In more systematic cases e.g. spe file is for MARI, and impose a mask file that leaves only the
%  low angle detectors, then the calculation will be off. Will bw able to rectify this once use
%  libisis run file structure, when can enquire of masked detectors from the IXTrunfile object)

if exist('urange_in','var')
    urange = urange_in;
else
    disp('--------------------------------------------------------------------------------')
    disp(['Calculating limits of data from ',num2str(nfiles),' spe files...'])
    % Read in the detector parameters if they are present in spe_data
    det=getPar(spe_data{1});
    if isempty(det)
        det=get_par(par_file);
    end
    % Get the maximum limits along the projection axes across all spe files
    data.filename='';
    data.filepath='';
    ndet=length(det.group);
    data.S=zeros(2,ndet);
    data.E=zeros(2,ndet);
    urange=[Inf, Inf, Inf, Inf;-Inf,-Inf,-Inf,-Inf];
    for i=1:nfiles

        eps=(spe_data{i}.en(2:end)+spe_data{i}.en(1:end-1))/2;
        if length(eps)>1
            data.en=[eps(1);eps(end)];
        else
            data.en=eps;
        end
        [u_to_rlu, ucoords] = calc_projections (efix(i), emode, alatt, angdeg, u, v, psi(i), ...
            omega(i), dpsi(i), gl(i), gs(i), data, det);
        urange = [min(urange(1,:),min(ucoords,[],2)'); max(urange(2,:),max(ucoords,[],2)')];
    end
    clear data det ucoords % Tidy memory
end

% Write temporary sqw output file(s) (these can be deleted if all has gone well once gen_sqw has been run)
% --------------------------------------------------------------------------------------------------------
% *** should check that the temporary file names do not coincide with spe file names

if nfiles==1
    tmp_file='';    % temporary file not created, so to avoid misleading return argument, set to empty string
    disp('--------------------------------------------------------------------------------')
    disp('Creating output sqw file:')
    grid_size = write_spe_to_sqw (spe_data{i}, par_file, sqw_file, efix(i), emode, alatt, angdeg,...
            u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i), grid_size_in, urange);
else
    nt=bigtic();
    for i=1:nfiles
        disp('--------------------------------------------------------------------------------')
        disp(['Processing spe file ',num2str(i),' of ',num2str(nfiles),':'])
        grid_size_tmp = write_spe_to_sqw (spe_data{i}, par_file, tmp_file{i}, efix(i), emode, alatt, angdeg,...
            u, v, psi(i), omega(i), dpsi(i), gl(i), gs(i), grid_size_in, urange);
        if i==1
            grid_size = grid_size_tmp;
        else
            if ~all(grid_size==grid_size_tmp)
                error('Logic error in code calling write_spe_to_sqw')
            end
        end
    end
    bigtoc(nt);
    % Create single sqw file combining all intermediate sqw files
    % ------------------------------------------------------------
    disp('--------------------------------------------------------------------------------')
    disp('Creating output sqw file:')
    if get(hdf_config,'use_hdf')
        sqwh = sqw_hdf(sqw_file,tmp_file);
        delete(sqwh);
    else    
        write_nsqw_to_sqw (tmp_file, sqw_file);
    end
    disp('--------------------------------------------------------------------------------')
end

% Delete temporary files as user will presumably use hdf and tmp files
if get(hor_config,'delete_tmp')
    if ~isempty(tmp_file)   % will be empty if only one spe file
        tmp_path=fileparts(tmp_file{1});
        delete([tmp_path,filesep,'*.tmp']);
    end
end


% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
