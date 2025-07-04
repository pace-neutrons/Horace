function [tmp_sqw, grid_size, img_db_range] = dummy_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg,...
    u, v, psi, omega, dpsi, gl, gs, varargin)
% Create an output sqw file with dummy data using array(s) of energy bins instead spe file(s).
%
%   >> dummy_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                    u, v, psi, omega, dpsi, gl, gs)
%
%   >> dummy_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg,...
%                    u, v, psi, omega, dpsi, gl, gs, grid_size_in, pix_range_in,run_id)
%
%   >> [tmp_file, grid_size, img_db_range] = dummy_sqw (...)
%
% Input:
% ------
%   en              Energy bin boundaries (must be monotonically increasing and equally spaced)
%               or  cell array of arrays of energy bin boundaries, one array per spe file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%                   or
%                   3xNdet array of [h,k,l] values corresponding to the
%                   detectors positions
%                   or
%                   3x3 matrix in the format [qh_min,qh_step,qh_max;
%                   qk_min,qk_step,qk_max;ql_min,q_step,q;_max] providing
%                   q-range
%                   The fake detectors positions used in sqw object calculations
%                   would be calculated from the q-range provided assuming
%                   elastic scattering (0-energy transfer)
%
%   sqw_file        Full file name of output sqw file, or empty string if
%                   one wants to return a dummy sqw object.
%
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
% Optional:
%   run_id         Number, larger than 1000 to distinguish if from possible
%                  scalar grid_size_in, which is too big to be 1000^4.
%                  If provided, specifies the unique number, which
%                  distinguish different runs one from another. If not,
%                  function generates tmp_sqw with default run_id == 1000. 
% WARNING:
%                  If you intend to generate multiple dummy_sqw objects in
%                  an external loop with different input parameters 
%                  with purpose to combine  them together later, you need
%                  to give them different run_id(s)
%                  Combine procedure will refuse combining tmp/sqw objects
%                  with the same run_id-s and different input parameters.
%                  
%   grid_size_in   Scalar or row vector of grid dimensions. The default
%                  size will depend on the product of energy bins and detector elements
%                  summed across all the spe files.
%   pix_db_range_in Range of grid used to rebin pixels. If not given, then uses smallest hyper-cuboid
%                   that encloses the whole pixels range.
%
% Output:
% --------
%   tmp_sqw        if return_sqw_obj is false (sqw_file is set up)
%                  the list of temporary file names used as parts of final
%                  sqw file.
%                  if return_sqw_obj == true --
%                  cellarray of sqw objects, each corresponding to
%                  generated tmp sqw file
%
%   grid_size      Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   img_db_range   The range of the grid (in Crystal Cartesian) on which
%                  the pixels are rebinned on.
%
%
% Use to generate an sqw file that can be used for creating simulations. Syntax very similar to
% gen_sqw: the only difference is that the input spe data is replaced by energy bin boundaries.


% T.G.Perring  18 May 2009

small_bin=1e-12;
%d2r=pi/180;

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
            error('HORACE:dummy_sqw:invalid_argument',...
                'Energy bins must numeric vectors')
        else
            de=diff(en{i});
            if any(de<=0) || any(abs(diff(de))/de(1)>small_bin)
                error('HORACE:dummy_sqw:invalid_argument',...
                    'Energy bins widths must all be the same and positive')
            end
            en_lo(i)=(en{i}(1)+en{i}(2))/2;
            en_hi(i)=(en{i}(end-1)+en{i}(end))/2;
        end
    end
else
    error('HORACE:dummy_sqw:invalid_argument',...
        'Energy bins must be an array of equally spaced energy bin boundaries')
end

% Check par and sqw file names
spe_file='';
require_spe_exist=false;
require_spe_unique=false;
require_sqw_exist=false;
if isempty(sqw_file)
    return_sqw_obj = true;
    sqw_file = '';%'never_generated_sqw_file.sqw';
else
    return_sqw_obj = false;
end

% Check emode, alatt, angdeg, u, v etc. and determine number of spe files
if numel(en)>1
    nfiles_in=numel(en); % no. datasets determined by number of energy arrays
else
    nfiles_in=[];        % no. datasets determine from length of arrays of other parameters
end
[ok,mess,efix,emode,lattice]=gen_sqw_check_params...
    (nfiles_in,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
if ~ok, error(mess), end
if efix(1)==0, error('HORACE:dummy_sqw:invalid_argument',...
        'Must have emode=1 (director geometry) or =2 (indirect geometry)'),
end



% A q-range at zero energy transfer is provided
if isnumeric(par_file)
    if ~isempty(nfiles_in) && nfiles_in>1
        error('HORACE:dummy_sqw:invalid_argument',...
            'dummy_sqw with q-range input can not generate multiple sqw files');
    end
    % now the par file is the
    par_file = build_det_from_q_range(par_file,efix,lattice);
end

if return_sqw_obj
    sqw_file = '';
end

[spe_file, par_file, sqw_file] = gen_sqw_check_files...
    (spe_file, par_file, sqw_file, require_spe_exist, require_spe_unique, require_sqw_exist);


nfiles=numel(efix);
if nfiles>1 && numel(en)==1
    en=repmat(en,1,nfiles);
    en_lo=en_lo*ones(1,nfiles);
    en_hi=en_hi*ones(1,nfiles);
end

% Check optional arguments (grid, pix_range, instrument, sample) for size, type and validity
grid_default=[];
instrument_default=IX_null_inst();  % default 1x1 structure with no fields
sample_default=IX_null_sample();      % default 1x1 structure with no fields
[present,grid_size,img_db_range,instrument,sample,run_id]=gen_sqw_check_optional_args(...
    nfiles,grid_default,instrument_default,sample_default,lattice,varargin{:});



% Create tmp files
% ------------------
run_files = rundatah.gen_runfiles(spe_file,par_file,efix,emode,lattice, ...
    instrument,sample,'-allow_missing');
run_file = run_files{1};
run_file.run_id = run_id(1);

ndet = run_file.n_detectors;
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
hor_log_level = get(hor_config, 'log_level');

% Determine pix_range
if isempty(img_db_range) 
    img_db_range = PixelDataBase.EMPTY_RANGE_;
    for i=1:numel(run_files)
        [pix_range_l,run_files{i}] = run_files{i}.calc_pix_range(en_lo(i),en_hi(i));
        img_db_range = [min(pix_range_l(1,:),img_db_range(1,:));max(pix_range_l(2,:),img_db_range(2,:))];
    end
    img_db_range=range_add_border(img_db_range,...
        SQWDnDBase.border_size);     % add a border to account for Matlab matrix multiplication bug
end

% Construct data structure with spe file information
if return_sqw_obj
    tmp_sqw = cell(1,nfiles);
else
    if nfiles == 1
        tmp_sqw={sqw_file};
    else
        % Create unique temporary sqw files, one for each of the energy bin arrays
        spe_file=repmat({''},[nfiles,1]);     % empty spe file names
        tmp_sqw=gen_tmp_filenames(spe_file,sqw_file);
        nt=bigtic();
    end
end
%
if(hor_log_level>-1)
    disp('--------------------------------------------------------------------------------')
    if return_sqw_obj
        disp('Creating output sqw object:')
    else
        disp('Creating output sqw file:')
    end
end
%
for i=1:nfiles
    if hor_log_level>-1 && nfiles>1
        disp('--------------------------------------------------------------------------------')
        disp(['Creating intermediate .tmp file ',num2str(i),' of ',num2str(nfiles),':'])
        disp(' ')
    end
    data=dummy_spe(ndet,en{i},psi(i));
    run_files{i}.S = data.S;
    run_files{i}.ERR = data.ERR;
    run_files{i}.en = en{i};
    run_files{i}.run_id = run_id(i);
    %
    w = run_files{i}.calc_sqw(grid_size, img_db_range);

    if return_sqw_obj
        tmp_sqw{i} = w;
    else
        save(w,tmp_sqw{i});
    end
end
%
if nfiles>1 && ~return_sqw_obj
    if hor_log_level>-1
        disp('--------------------------------------------------------------------------------')
        bigtoc(nt,'Time to create all intermediate .tmp files:',hor_log_level);
        disp('--------------------------------------------------------------------------------')
        disp('Creating output sqw file:')
    end
    write_nsqw_to_sqw (tmp_sqw, sqw_file);
    % Delete tmp files
    delete_error=false;
    for i=1:numel(tmp_sqw)
        try
            delete(tmp_sqw{i})
        catch
            if delete_error==false
                delete_error=true;
                if hor_log_level>-1
                    disp('One or more intermediate .tmp files not deleted')
                end
            end
        end
    end

end

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size pix_range
end
