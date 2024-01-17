function [ok,mess,lookup,npix] = tobyfit_DGfermi_resconv_init (win, varargin)
% Fill various lookup tables and matrix transformations for resolution calculations
%
% For all pixels in the input sqw object(s):
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win)
%
% For specific pixels:
%   >> [ok,mess,lookup]=tobyfit_DGfermi_resconv_init(win,ipix)
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
% [Optional]
%   ipix        Pixel indices for which the output is to be extracted from the
%               sqw object(s). It has the form of one of:
%
%               - Array of pixel indices. If there are multiple sqw objects,
%                 it is then applied to every sqw object
%
%               - Cell array of pixel indices arrays
%                   - only one array: applied to every sqw object, or
%                   - several pixel indices arrays: one per sqw object
%
%   opt         Option: 'tables' (default) or 'notables'
%               If 'tables', then object_lookup tables for instrument
%              components, sample and detectors are added to the output
%              argument lookup
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
%               with the indexing argument ipix. (Array has same size as win)
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
%           alatt       Lattice parameters (Angstroms), vector size [1,3]
%           angdeg      Lattice angles in degrees (Angstroms), vector size [1,3]
%           is_mosaic   Logical flag: true if a sample for at least one run in
%                      the sqw object has a non-zero mosaic spread, scalar [1,1]
%
%       Cell array of widths of energy bins, one array per dataset
%           dt          Time widths for each pixel (s), size [npix,1]
%
%       Cell array of energy bin centres, one array per dataset
%           en          Vector of size [1,npix] with components of energy
%                       for each pixel
%
%       Constants:
%           k_to_e      Constant in E(mev)=k_to_e*(k(Ang^-1))^2
%           k_to_v      Constant in v(m/s)=k_to_v*k(Ang^-1)
%
%
% *OR*
%   mc_contr    Cell array of character strings with the names of the
%              possible contributions e.g. {'chopper','moderator'}


% Use 3He cylindrical gas tube (true) or Tobyfit original (false)
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
    ipix = args{1};
elseif numel(args)>0
    ok = false;
    mess = 'Check the number of input arguments';
    return
end


% Check pixel indexing is valid
% -----------------------------
all_pixels = ~exist('ipix','var');
if ~all_pixels
    % Perform consistency checks of the pixel indices against the sqw objects
    % if particular indices are selected
    parse_pixel_indices (win, ipix);
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
is_mosaic=cell(nw,1);   % element size [1,1]
detectors=cell(nw,1);   % element size [nrun,1]
dt=cell(nw,1);          % element size [npix,1]
en=cell(nw,1);          % element size [npix,1]


% Get detector information for the entire collection of sqw objects as an
% instance of the object_lookup class
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

    % Get IX_detector_array for the sqw object
    detectors{iw} = detector_array (wtmp, use_tubes);
end
% Because the detector info extraction above still assumes that there is
% only one IX_detector_array per sqw (rather than possibly a different one for
% each run), for the moment continue to fill the object_lookup for detectors
% with repeats by n_runs for each sqw object
sz_cell = num2cell([n_runs, ones(nw,1)], 2);    % sz_repeat for object_lookup
detector_table = object_lookup(detectors, 'repeat', sz_cell);


% Get quantities and derived quantities from the header
for iw=1:nw
    % Get pointer to a specific sqw pobject
    if iscell(win)
        wtmp = win{iw};
    else
        wtmp = win(iw);
    end

    % Get the indices to the runs in the experiment information block, the
    % detector indicies and the energy bin indices
    if all_pixels
        % For all pixels in the sqw object
        [irun, idet, ien] = parse_pixel_indices(wtmp);
    elseif iscell(ipix) && numel(ipix)>1
        % Different ipix arrays for each sqw object
        [irun, idet, ien] = parse_pixel_indices(wtmp, ipix{iw});
    else
        % Single ipix array for all sqw objects
        [irun, idet, ien] = parse_pixel_indices(wtmp, ipix);
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

    % Get array of mosaic spreads for the runs, and determine if any of them
    % have other than the default of no spread
    mosaic = arrayfun (@(x)(x.eta), sample{iw});
    is_mosaic{iw} = any(mosaic_crystal(mosaic));

    % Get detector information for each pixel in the sqw object
    % size(x2) = [npix,1], size(d_mat) = [3,3,npix]
    [x2, detdcn] = detector_table.func_eval_ind (iw, irun, idet, @detector_info);

    % Time width corresponding to energy bins for each pixel
    dt{iw} = deps_to_dt*(x2.*deps(irun)./kf{iw}.^3);

    en{iw} = eps;

end

% Package output
ok=true;
mess='';
lookup = struct();    % reinitialise

% Lookup tables to minimise memory and optimise speed of random sampling
if keywrd.tables
    lookup.moderator_table = object_lookup(moderator);
    lookup.aperture_table = object_lookup(aperture);
    lookup.fermi_table = object_lookup(chopper);
    % Expand indexing of object_lookup for the sample to refer to n_runs copies
    % (recall one element of n_runs per sqw object)
    lookup.sample_table = object_lookup(sample, 'repeat', sz_cell);
    lookup.detector_table = detector_table;     % already an object_lookup
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
lookup.is_mosaic=is_mosaic;
lookup.dt=dt;
lookup.en=en;
lookup.k_to_v=k_to_v;
lookup.k_to_e=k_to_e;

if iscell(win)
    lookup = {lookup};  % make it a cell array length unity if win was a cell array
end
