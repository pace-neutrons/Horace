function [ok,mess,lookup,npix] = tobyfit_DGfermi_resconv_init (win, varargin)
% Fill various lookup tables and matrix transformations for resolution calculations
%
% For all pixels in the input sqw object(s):
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win)
%
% For specific pixels:
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win,indx)
%
% No lookup tables:
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(...,'notables')
%
% Special case of recovering the Monte Carlo contribution options:
%   >> [ok,mess,mc_contr]=tobyfit_DGfermi_resconv_init
%
%
% This routine is used in Tobyfit resolution convolution, and by other methods
% that need to know about resolution functions. Note that for Tobyfit the
% constraints of the mfclass_class object for initialisation function have a very
% specific function call: [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win) i.e
% no other optional parameters.
%
% Input:
% ------
%   win         Array of sqw objects, or cell array of scalar sqw objects
%
%  [Optional]
%   indx        Pixel indices:
%
%               Single sqw object:
%               ------------------
%                 - ipix            Array of pixels indices
%            *OR* - {irun,idet,ien} Arrays of run, detector and energy bin index
%                                   Dimension expansion is performed on scalar
%                                  quantities i.e. each must be a scalar or array
%                                  with arrays having the same length
%
%               Multiple sqw objects:
%               ---------------------
%                 - As above, assumed to apply to all sqw objects,
%            *OR* - Cell array of the above, one cell array per sqw object
%                  e.g. if two sqw objects:
%                       {ipix1, ipix2}
%                       {{irun1,idet1,ien1}, {irun2,idet2,ien2}}
%
%   opt         Option: 'tables' (default) or 'notables'
%               If 'tables', then moderator and Fermi chopper lookup tables
%              are added to the output argument lookup
%
%
% Output:
% -------
%   ok          Status flag: =true if all ok, =false otherwise
%
%   mess        Error message: empty if ok, contains error message if not ok
%
%   lookup      Lookup tables and pre-calculated matricies etc.
%               - If win was an sqw object or array of sqw objects, then lookup
%                is a structure
%               - If win was a cell array of sqw objects, then lookup is a cell
%                array with that structure as the single element
%
%               For details of contents of lookup, see below.
%
%   npix        Array of number of pixels for each workspace after selecting
%               with the indexing argument indx. (Array has same size as win)
%
%
% Contents of output argument: lookup
% -----------------------------------
%       Indexed lookup tables: object_lookup objects
%           moderator_table     Index: [isqw, irun] (note: times in microseconds)
%           aperture_table      Index: [isqw, irun]
%           fermi_table         Index: [isqw, irun] (note: times in microseconds)
%           sample_table        Index: [1, isqw]
%           detector_table      Index: [1, isqw]
%
%       Cell array of arrays, one array per dataset, each array with length equal to
%      the number of runs in each dataset:
%           ei          Incident energies (mev)             [Column vector]
%           x0          Moderator - chopper distance (m)    [Column vector]
%           xa          Beam defining aperture - chopper distance (m)       [Column vector]
%           x1          Chopper - sample distance (m)       [Column vector]
%           thetam      Angle of moderator normal to incident beam (rad)    [Column vector]
%           angvel      Chopper angular velocity (rad/s)    [Column vector]
%
%       Cell arrays of incident and final wavevectors, one array per dataset
%           ki          Incident wavevectors [Column vector, length nruns]
%           kf          Final wavevectors [Column vector, length npix]
%
%       Cell arrays of arrays of transformation matricies, one array per dataset:
%           s_mat       Matrix to convert coords in sample frame to spectrometer frame.
%                      Size is [3,3,nrun], where nrun is the number of runs
%           spec_to_rlu Matrix to convert momentum in spectrometer coordinates to
%                      components in r.l.u.:
%                           v_rlu = spec_to_rlu * v_spec
%                      Size is [3,3,nrun], where nrun is the number of runs
%           alatt       Lattice parameters (Angstroms), vector size[1,3]
%           angdeg      Lattice angles in degrees (Angstroms), vector size[1,3]
%
%       Cell arrays of arrays of detector information, one array per dataset:
%           f_mat       Array size [3,3,ndet] to take coordinates in spectrometer
%                      frame and convert into secondary spectrometer frame.
%
%           d_mat       Array size [3,3,ndet] to take coordinates in detector
%                      frame and convert into secondary spectrometer frame.
%
%           detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%
%           x2          Sample-detector distances (m) (size [ndet,1])
%
%       Cell array of widths of energy bins, one array per dataset
%           dt          Time widths for each pixel (s), size [npix,1]
%
%       Cell arrays of q,w and transformation arrays, one array per dataset
%           qw          Cell array size [1,4] with components of momentum (in rlu) and energy
%                        for each pixel [Columns of size npix]
%
%           dq_mat      Array of matricies, size [4,11,npix],  to convert deviations in
%                      tm, tch etc. into deviations in Q in rlu
%
%       Constants:
%           k_to_e      Constant in E(mev)=k_to_e*(k(Ang^-1))^2
%           k_to_v      Constant in v(m/s)=k_to_v*k(Ang^-1)
%
%
% *OR*
%   mc_contr    Cell array of character strings with the names of the
%              possible contributions e.g. {'chopper','moderator'}


% Use 3He cylindrical gas tube (ture) or Tobyfit original (false)
use_tubes=false;

% Catch case of inquiry about mc_contributions
% --------------------------------------------
if nargin==0
    ok=true;
    mess='';
    lookup={'moderator','aperture','chopper','sample',...
        'detector_depth','detector_area','energy_bin','mosaic'};
    npix = [];
    return
end


% Initialise output lookup
% ------------------------
nw = numel(win);
lookup = struct([]);    % empty structure with no fields
if iscell(win)
    lookup = {lookup};
end
npix = zeros(size(win));


% Check optional arguments
% ------------------------
keywrd_def = struct('tables',1);
flags = {'tables'};
[args,keywrd] = parse_arguments (varargin,keywrd_def,flags);
if numel(args)==1
    indx = args{1};
elseif numel(args)>0
    ok = false;
    mess = 'Check the number of input arguments';
    return
end


% Check pixel indexing is valid
% -----------------------------

all_pixels = ~exist('indx','var');
if ~all_pixels
    parse_pixel_indices (win,indx);
end


% Create lookup
% -------------
% Get some constants
c=neutron_constants;
k_to_e = c.c_k_to_emev;     % E(mev)=k_to_e*(k(Ang^-1))^2
k_to_v = 1e6/c.c_t_to_k;    % v(m/s)=k_to_v*k(Ang^-1)
deps_to_dt = 0.5e-6*c.c_t_to_k/c.c_k_to_emev;   % dt(s)=deps_to_dt*x2(m)/kf(Ang^-1)^3 * deps(meV)

% Pre-calculate and store various quantities to save time during simulation and fitting
ei=cell(nw,1);          % element size [nrun,1]
x0=cell(nw,1);          %       "
xa=cell(nw,1);          %       "
x1=cell(nw,1);          %       "
thetam=cell(nw,1);      %       "
angvel=cell(nw,1);      %       "
moderator=cell(nw,1);   %       "
aperture=cell(nw,1);    %       "
chopper=cell(nw,1);     %       "
ki=cell(nw,1);          %       "
kf=cell(nw,1);          % element size [npix,1]
sample=cell(nw,1);      % element size [nrun,1]
s_mat=cell(nw,1);       % element size [3,3,nrun]
spec_to_rlu=cell(nw,1); % element size [3,3,nrun]
alatt=cell(nw,1);       % element size [1,3]
angdeg=cell(nw,1);      % element size [1,3]
detectors=cell(nw,1);   % element size [nrun,1]
f_mat=cell(nw,1);       % element size [3,3,ndet]
d_mat=cell(nw,1);       % element size [3,3,ndet]
detdcn=cell(nw,1);      % element size [3,ndet]
x2=cell(nw,1);          % element size [ndet,1]
dt=cell(nw,1);          % element size [npix,1]
qw=cell(nw,1);          % element is cell array size [1,4], each element size [npix,1]
dq_mat=cell(nw,1);      % element size [4,11,npix]


% Get quantities and derived quantities from the header
n_runs = NaN(nw,1);
for iw=1:nw
    % Get pointer to a specific sqw pobject
    if iscell(win)
        wtmp = win{iw};
    else
        wtmp = win(iw);
    end
    
    % Get number of runs in the sqw object
    n_runs(iw) = wtmp.experiment_info.n_runs;
    
    % Pixel indicies
    if all_pixels
        [irun,idet,ien] = parse_pixel_indices(wtmp);
    else
        [irun,idet,ien] = parse_pixel_indices(wtmp,indx,iw);
    end
    npix(iw) = numel(irun);
    
    % Get energy transfer and bin sizes
    % (Could get eps directly from wtmp.data.pix(:,4), but this does not work if the
    %  pixels have been shifted, so recalculate)
    
    [deps,eps_lo,eps_hi,ne]=energy_transfer_info(wtmp.experiment_info);
    
    if ne>1
        eps=(eps_lo(irun).*(ne(irun)-ien)+eps_hi(irun).*(ien-1))./(ne(irun)-1);
    else
        eps=eps_lo;     % only one bin, so ne=1 eps_lo=eps_hi, and the above line fails
    end
    
    % Get instrument information
    [ei{iw},x0{iw},xa{iw},x1{iw},thetam{iw},angvel{iw},...
        moderator{iw},aperture{iw},chopper{iw}] = instpars_DGfermi(wtmp.experiment_info);
    
    % Compute ki and kf
    ki{iw}=sqrt(ei{iw}/k_to_e);
    kf{iw}=sqrt((ei{iw}(irun)-eps)/k_to_e);
    
    % Get sample, and both s_mat and spec_to_rlu; each has size [3,3,nrun]
    [sample{iw},s_mat{iw},spec_to_rlu{iw},alatt{iw},angdeg{iw}] =...
        sample_coords_to_spec_to_rlu(wtmp.experiment_info);
    
    % Get detector information
    % Because detpar only contains minimal information, either hardwire in 
    % the detector type here or use the info now available in the detector
    % arrays
    detpar = wtmp.detpar();   % just get a pointer
    det = wtmp.experiment_info.detector_arrays;
    if isempty(det) || det.n_runs == 0
        % no detector info was available when the sqw was populated, so
        % continue with the old detector initialisation from detpar
        if use_tubes
            detectors{iw} = IX_detector_array (detpar.group, detpar.x2(:), ...
                detpar.phi(:), detpar.azim(:),...
                IX_det_He3tube (detpar.width, detpar.height, 6.35e-4, 10));   % 10atms, wall thickness=0.635mm
        else
            detectors{iw} = IX_detector_array (detpar.group, detpar.x2(:), detpar.phi(:), detpar.azim(:),...
                IX_det_TobyfitClassic (detpar.width, detpar.height));
        end
    else
        % make a new detector object based on value of use_tubes and insert
        % it into the detector_array info extracted from the sqw
        if det.n_unique_objects>1
            error('HORACE:tobyfit_DGfermi_resconv_init:incorrect_size', ...
                  ['all sqw runs must have identical detectors with this ', ...
                   'implementation']);
        else
            det = det{1}; % first run detector array element is the same for all runs
                          % so equivalent to the content in detpar
            bank = det.det_bank; % get out its detector bank 
            % create a new detector object for this based on the detector
            % bank info stored in the sqw object
            current_detobj = bank.det;
            width = current_detobj.dia;
            height = current_detobj.height;
            if use_tubes
                % wall thickness 6.35e-4 and pressure 10 remain hardwired
                detobj = IX_det_He3tube(width, height, 6.35e-4, 10);
            else
                detobj = IX_det_TobyfitClassic(width, height);
            end
            % restore detector object to the bank
            bank.det  = detobj;
            % and restore the bank to the detector array
            det.det_bank = bank;
            % and store the array in the initializer for the detector
            % object lookup below.
            % NOTE that the detectors in experiment_info have not
            % themselves been updated.
            detectors{iw} = det;
        end
    end
    x2{iw} = detectors{iw}.x2;
    d_mat{iw} = detectors{iw}.dmat;
    f_mat{iw} = spec_to_secondary(detectors{iw});
    detdcn{iw} = det_direction(detectors{iw});
    
    % Time width corresponding to energy bins for each pixel
    dt{iw} = deps_to_dt*(x2{iw}(idet).*deps(irun)./kf{iw}.^3);
    
    % Calculate h,k,l (symmetrised objects will not have true pixel coordinates)
    qw{iw} = cell(1,4);
    qw{iw}(1:3) = calculate_q (ki{iw}(irun), kf{iw}, detdcn{iw}(:,idet), spec_to_rlu{iw}(:,:,irun));
    qw{iw}{4} = eps;
    
    % Matrix that gives deviation in Q (in rlu) from deviations in tm, tch etc. for each pixel
    dq_mat{iw} = dq_matrix_DGfermi (ki{iw}(irun), kf{iw},...
        x0{iw}(irun), xa{iw}(irun), x1{iw}(irun), x2{iw}(idet), thetam{iw}(irun), angvel{iw}(irun),...
        s_mat{iw}(:,:,irun), f_mat{iw}(:,:,idet), d_mat{iw}(:,:,idet),...
        spec_to_rlu{iw}(:,:,irun), k_to_v, k_to_e);
    
end

% Package output as a structure, in cell array length unity if win was a cell array
ok=true;
mess='';
lookup = struct();    % reinitialise

% Lookup tables to minimise memory and optimise speed of random sampling
if keywrd.tables
    lookup.moderator_table = object_lookup(moderator);
    lookup.aperture_table = object_lookup(aperture);
    lookup.fermi_table = object_lookup(chopper);
    % Expand indexing of lookups to refer to n_runs copies (recall one element
    % of n_runs per sqw object)
    sz_cell = num2cell([n_runs, ones(nw,1)], 2);    % sz_repeat for object_lookup
    lookup.sample_table = object_lookup(sample, 'repeat', sz_cell);
    % as the detector info extraction above still assumes that there is
    % only one detector per sqw rather than one for each runs (a fully
    % populated but compressed array), for the moment continue to fill the
    % object_lookup for detectors with repeats
    lookup.detector_table = object_lookup(detectors, 'repeat', sz_cell);
end
lookup.ei=ei;
lookup.x0=x0;
lookup.xa=xa;
lookup.x1=x1;
lookup.thetam=thetam;
lookup.angvel=angvel;
lookup.ki=ki;
lookup.kf=kf;
lookup.s_mat=s_mat;
lookup.spec_to_rlu=spec_to_rlu;
lookup.alatt=alatt;
lookup.angdeg=angdeg;
lookup.f_mat=f_mat;
lookup.d_mat=d_mat;
lookup.detdcn=detdcn;
lookup.x2=x2;
lookup.dt=dt;
lookup.qw=qw;
lookup.dq_mat=dq_mat;
lookup.k_to_v=k_to_v;
lookup.k_to_e=k_to_e;

if iscell(win)
    lookup = {lookup};
end
