function [tmp_file, grid_size, urange] = fake_sqw (dummy_sqw, en, par_file, sqw_file, efix, emode, alatt, angdeg,...
                    u, v, psi, omega, dpsi, gl, gs, varargin)
% Create an output sqw file with dummy data using array(s) of energy bins instead spe file(s).
%
%   >> fake_sqw (sqw, en, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                    u, v, psi, omega, dpsi, gl, gs)
%
%   >> fake_sqw (sqw, en, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                    u, v, psi, omega, dpsi, gl, gs, grid_size_in, urange_in)
%
%   >> [tmp_file, grid_size, urange] = fake_sqw (...)
%
% Input:
% ------
%   dummy_sqw       Dummy sqw object  - used only to ensure that this service routine was called
%   en              Energy bin boundaries (must be monotonically increasing and equally spaced)
%               or  cell array of arrays of energy bin boundaries, one array per spe file
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
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions. The default
%                  size will depend on the product of energy bins and detector elements
%                  summed across all the spe files.
%   urange_in       [Optional] Range of data grid for output. If not given, then uses smallest hypercuboid
%                                       that encloses the whole data range.
%
% Output:
% --------
%   tmp_file        List of temporary file names
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid
%
%
% Use to generate an sqw file that can be used for creating simulations. Syntax very similar to
% gen_sqw: the only difference is that the input spe data is replaced by energy bin boundaries.


% T.G.Perring  18 May 2009
%
% $Revision$ ($Date$)

small_bin=1e-12;
d2r=pi/180;

% Check input arguments
% ------------------------
% Input energy bins
if iscellnum(en) || isnumeric(en)
    if isnumeric(en)
        en={en};
    end
    en_lo=zeros(1,numel(en));
    en_hi=zeros(1,numel(en));
    for i=1:numel(en)
        if ~isvector(en{i}) || numel(en{i})<2
            error('Energy bins must numeric vectors')
        else
            de=diff(en{i});
            if any(de)<=0 || any(abs(diff(de))/de(1)>small_bin)
                error('Energy bins widths must all be the same and non-zero')
            end
            en_lo(i)=(en{i}(1)+en{i}(2))/2;
            en_hi(i)=(en{i}(end-1)+en{i}(end))/2;
        end
    end
else
    error('Energy bins must be an array of equally spaced energy bin boundaries')
end

% Check par and sqw file names
spe_file='';
require_spe_exist=false;
require_spe_unique=false;
require_sqw_exist=false;
[ok, mess, spe_file, par_file, sqw_file] = gen_sqw_check_files...
    (spe_file, par_file, sqw_file, require_spe_exist, require_spe_unique, require_sqw_exist);
if ~ok, error(mess), end


% Check emode, alatt, angdeg, u, v etc. and determine number of spe files
if numel(en)>1
    nfiles_in=numel(en); % no. datasets determined by number of energy arrays
else
    nfiles_in=[];        % no. datasets determine from length of arrays of other parmaeters
end
[ok,mess,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs]=gen_sqw_check_params...
    (nfiles_in,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
if ~ok, error(mess), end
if efix(1)==0, error('Must have emode=1 (director geometry) or =2 (indirect geometry)'), end

nfiles=numel(efix);
if nfiles>1 && numel(en)==1
    en=repmat(en,1,nfiles);
    en_lo=en_lo*ones(1,nfiles);
    en_hi=en_hi*ones(1,nfiles);
end

% Check optional arguments (grid, urange, instument, sample) for size, type and validity
grid_default=[];
instrument_default=struct;  % default 1x1 struct
sample_default=struct;      % default 1x1 struct
[ok,mess,present,grid_size,urange,instrument,sample]=gen_sqw_check_optional_args(...
    nfiles,grid_default,instrument_default,sample_default,varargin{:});
if ~ok, error(mess), end


% Create tmp files
% ------------------
% Read par file
det=get_par(par_file,'-hor');
ndet=size(det.x2,2);

% Determine a grid size if not given one on input
if isempty(grid_size)
    av_npix_per_bin=1e4;
    ne=0;
    for i=1:nfiles
        ne=ne+numel(en{i});
    end
    npix=ne*ndet;
    grid_size=ceil(sqrt(sqrt(npix/av_npix_per_bin)));
end

% Determine urange
if isempty(urange)
    urange=calc_urange(efix,emode,en_lo,en_hi,det,alatt,angdeg,...
        u,v,psi*d2r,omega*d2r,dpsi*d2r,gl*d2r,gs*d2r);
    urange=range_add_border(urange,-1e-6);     % add a border to account for Matlab matrix multiplication bug
end

% Construct data structure with spe file information
if nfiles==1
    % Create sqw file in one step: no need to create an intermediate file as just one input spe file to convert
    disp('--------------------------------------------------------------------------------')
    disp('Creating output sqw file:')
    data=fake_spe(ndet,en{1},psi);
    w=calc_sqw(efix, emode, alatt, angdeg, u, v, psi*d2r, omega*d2r, dpsi*d2r, gl*d2r, gs*d2r,...
        data, det, det, grid_size, urange, instrument, sample);
    save(w,sqw_file)
    tmp_file={};    % empty cell array to indicate no tmp_files created
    
else
    % Create unique temporary sqw files, one for each of the energy bin arrays
    spe_file=repmat({''},[nfiles,1]);     % empty spe file names
    tmp_file=gen_tmp_filenames(spe_file,sqw_file);
    nt=bigtic();
    for i=1:nfiles
        disp('--------------------------------------------------------------------------------')
        disp(['Creating intermediate .tmp file ',num2str(i),' of ',num2str(nfiles),':'])
        disp(' ')
        data=fake_spe(ndet,en{i},psi(i));
        w=calc_sqw(efix(i), emode(i), alatt(i,:), angdeg(i,:), u(i,:), v(i,:),...
            psi(i)*d2r, omega(i)*d2r, dpsi(i)*d2r, gl(i)*d2r, gs(i)*d2r,...
            data, det, det, grid_size, urange, instrument(i), sample(i));
        save(w,tmp_file{i})
    end
    disp('--------------------------------------------------------------------------------')
    bigtoc(nt,'Time to create all intermediate .tmp files:');
    disp('--------------------------------------------------------------------------------')
    
    % Create single sqw file combining all intermediate sqw files
    disp('Creating output sqw file:')
    write_nsqw_to_sqw (tmp_file, sqw_file);
    
    disp('--------------------------------------------------------------------------------')
    % Delete tmp files
    delete_error=false;
    for i=1:numel(tmp_file)
        try
            delete(tmp_file{i})
        catch
            if delete_error==false
                delete_error=true;
                disp('One or more intermediate .tmp files not deleted')
            end
        end
    end
    
end

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
